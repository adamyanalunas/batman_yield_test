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
      @viewArticle

  switchArticle: (options) ->
    id = parseInt(options.id, 10)
    foundArticle = @get('articles').find (article) ->
      article if article.get('id') == id

    # TODO: Look at all the forcing I have to do. Move this to more data bound stuff
    @set 'currentArticle', foundArticle
    @set('articleController.article', foundArticle)
    @index()

  renderMain: ->
    @render source: 'main/index', into: 'main', conext: @

  showFirstLesson: ->
    firstLesson = @get('currentArticle.lessons').find (lesson) ->
      lesson if lesson.get('id') != undefined
    @viewLesson id: firstLesson.get('id')

  clearArticles: ->
    YieldDemo.Lesson.load (err, lessons) ->
      lessons?.forEach (lesson) -> lesson.destroy()
    YieldDemo.Article.load (err, articles) ->
      articles?.forEach (article) -> article.destroy()

  # Substitute this with calls to a real db
  loadArticles: (cb) ->
    YieldDemo.Article.load (err, articles) ->
      if not articles?.length
        dogArticle = YieldDemo.Article::generateDogArticle()
        catArticle = YieldDemo.Article::generateCatArticle()

        cb?(new Batman.Set(dogArticle, catArticle))

  index: (args) ->
    @showFirstLesson()

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
    # TODO: This is bad
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
