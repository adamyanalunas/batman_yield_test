class YieldDemo.MainController extends Batman.Controller
  routingKey: 'main'

  constructor: ->
    @set 'articleController', new YieldDemo.ArticleController
    @get('articleController').on 'lessonLoaded', (lesson) ->
      console.log 'OHAY, I LOADED LESSON #', lesson.get('id'), ' for article #', lesson.get('article.id')

    @clearArticles()
    @loadArticles (articles) =>
      @set 'articles', articles
      # This feels bad
      params = YieldDemo.get('currentParams')
      articleId = parseInt(params.get('articleId') ? 1, 10)

      foundArticle = articles.find (article) ->
        article if article.get('id') == articleId

      @set 'currentArticle', foundArticle ? articles.get('first')
      @get('articleController').set 'article', @get('currentArticle')
      # @set 'tocController', new YieldDemo.TocController(articles: articles)
      @viewArticle

  switchArticle: (options) ->
    console.log 'switchArticle', options.id
    id = parseInt(options.id, 10)
    console.log 'id', id
    foundArticle = @get('articles').find (article) ->
      article if article.get('id') == id

    # TODO: Look at all the forcing I have to do. Move this to more data bound stuff
    @set 'currentArticle', foundArticle
    @set('articleController.article', foundArticle)
    @index()
    # Batman.redirect '/home'

  renderMain: ->
    @render source: 'main/index', into: 'main', conext: @

  clearArticles: ->
    YieldDemo.Lesson.load (err, lessons) ->
      lessons?.forEach (lesson) -> lesson.destroy()
    YieldDemo.Article.load (err, articles) ->
      articles?.forEach (article) -> article.destroy()

  # Substitute this with calls to a real db
  loadArticles: (cb) ->
    YieldDemo.Article.load (err, articles) ->
      if not articles?.length
        dogLessons = YieldDemo.Lesson::generateDogs()
        dogArticle = new YieldDemo.Article title: 'DOGZ RULE CATS DRULE!', lessons: dogLessons, blurb: 'Talk about dogs'
        dogArticle.save()

        catLessons = YieldDemo.Lesson::generateCats()
        catArticle = new YieldDemo.Article title: 'Cats, clearly, are superior', lessons: catLessons, blurb: 'Talk about cats'
        catArticle.save()

        cb?(new Batman.Set(dogArticle, catArticle))

  index: (args) ->
    firstLesson = @get('currentArticle.lessons').find (lesson) ->
      lesson if lesson.get('id') != undefined
    @viewLesson id: firstLesson.get('id')

  viewLesson: (options) ->
    @renderMain()

    lessonId = parseInt(options.id, 10)
    lesson = @get('currentArticle.lessons').find (lesson) =>
      lesson if lesson.get('id') == lessonId

    if lesson
      @get('articleController').viewLesson lesson
    else
      console.log 'redirect to id', @get('currentArticle.id'), 'from', @get('currentArticle')
      Batman.redirect 'articles/' + @get('currentArticle.id')

  # viewArticleLesson: (options) ->
  #   console.log 'viewArticleLesson', options

class YieldDemo.ArticleController extends Batman.Controller
  routingKey: 'article'

  constructor: (options) ->
    @setup options
    super

  @accessor 'lessons',
    get: ->
      @get('article.lessons')

  setup: (options) ->
    @unset 'activeLesson'
    @set 'article', options?.article
    @set 'lessonController', new YieldDemo.LessonsController

  render: (options) ->
    view = super
    view.on 'ready', =>
      # Could use @accessor here to @lessons.filter
      @fire 'lessonLoaded', @get('activeLesson')
    view

  show: (options) ->
    console.log 'article show', options

  viewLesson: (lesson) ->
    @get('lessons').forEach (inactiveLesson) ->
      inactiveLesson.unset 'active'
    lesson.set 'active', true
    # This could be moved to an @accessor
    @set 'activeLesson', lesson
    # @render into: 'article', source: lesson.get('source'), context: @
    @render into: 'article', source: 'articles/show', context: @
    @get('lessonController').viewLesson lesson

class YieldDemo.LessonsController extends Batman.Controller
  routingKey: 'lessons'

  show: (options) ->
    mc = YieldDemo.MainController.get('sharedController')
    # mc.switchArticle id: options.articleId
    mc.viewLesson id: options.id

  viewLesson: (lesson) ->
    @render into: 'lesson', source: lesson.get('source'), context: @

  render: (options) ->
    return if not options
    view = super
    view.on 'ready', =>
      # Could use @accessor here to @lessons.filter
      @fire 'lessonLoaded'
    view

class YieldDemo.TocController extends Batman.Controller
  routingKey: 'toc'

  constructor: (options) ->
    @set 'articles', options.articles
    # console.log 'toc article', @articles
    @render into: 'toc', context: @, source: '<p>poop</p>'

  render: ->
    console.log 'wee render'
    super
