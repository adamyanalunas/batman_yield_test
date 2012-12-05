class YieldDemo.MainController extends Batman.Controller
  routingKey: 'main'

  constructor: ->
    @articleController = new YieldDemo.ArticleController
    @articleController.on 'lessonLoaded', (lesson) ->
      console.log 'OHAY, I LOADED LESSON #', lesson.get('id')#, lesson

    @clearArticles()
    @loadArticles (articles) =>
      @article = @currentArticle = articles.toArray()[0]
      @articleController.set 'article', @article
      @viewArticle

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
        dogArticle = new YieldDemo.Article title: 'DOGZ RULE, CATS DRUL!', lessons: dogLessons, blurb: 'Talk about dogs'
        dogArticle.save()

        catLessons = YieldDemo.Lesson::generateCats()
        catArticle = new YieldDemo.Article title: 'Clearly cats are superior', lessons: catLessons, blurb: 'Talk about cats'
        catArticle.save()

        cb?(new Batman.Set(dogArticle, catArticle))

  index: (args) ->
    @viewLesson id: 1

  viewLesson: (options) ->
    @renderMain()
    @currentArticle.get('lessons').forEach (lesson) =>
      # This is implementation-specific
      if lesson.get('id') == parseInt(options.id, 10)
        @articleController.viewLesson lesson

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
    console.log 'article render', options
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
