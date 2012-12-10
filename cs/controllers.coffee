class YieldDemo.MainController extends Batman.Controller
  routingKey: 'main'

  constructor: ->
    console.log 'WUT'
    # @set 'articlesController', new YieldDemo.ArticlesController
    YieldDemo.ArticlesController.get('sharedController').on 'lessonLoaded', (lesson) ->
      console.log 'OHAY, I LOADED LESSON #', lesson.get('id'), ' for article #', lesson.get('article.id')

  index: (args) ->

class YieldDemo.ArticlesController extends Batman.Controller
  @beforeFilter (options) =>
    if options.action == 'show'
      @fire 'willShow', options

  @afterFilter (options) =>
    if options.action == 'show'
      @fire 'didShow', options

  routingKey: 'articles'

  constructor: (options) ->
    @setup options
    super

  @accessor 'lessons',
    get: ->
      @get('article.lessons')

  @accessor 'activeLesson',
    get: ->
      activeLesson = @get('lessons').find (lesson) ->
        lesson if lesson.get('active') == true

      activeLesson

  setup: (options) ->
    @set 'articles', YieldDemo.Article.get('all')
    # @set 'articles', YieldDemo.get('articles')
    @set 'article', options?.article
    # lessonController = new YieldDemo.LessonsController
    lessonController = YieldDemo.LessonsController.get('sharedController')
    # lessonController.articlesController = @
    @set 'lessonController', lessonController
    console.log 'lc', @get('lessonController')

  render: (options) ->
    view = super
    view.on 'ready', =>
      @fire 'lessonLoaded', @get('activeLesson')
    view

  show: (options) ->
    @switchArticle options

  viewLesson: (options) ->
    # Loading from the model will break the data binding.
    # Use the current article to preserve binding.
    lesson = @get('article.lessons').find (lesson) =>
      @set 'lesson', lesson if lesson.get('id') == parseInt(options.id, 10)

    unless @get('lesson')
      return Batman.redirect '/home'

    @get('article.lessons').forEach (inactiveLesson) ->
      inactiveLesson.unset 'active'
    lesson.set 'active', true

    # TODO: This is bad
    @render into: 'article', source: 'articles/show', context: @
    @get('lessonController').viewLesson lesson

  switchArticle: (options) ->
    foundArticle = @get('articles').find (article) =>
      @set('article', article) if article.get('id') == parseInt(options.id, 10)

    console.log foundArticle
    foundArticle.set 'active', true

class YieldDemo.LessonsController extends Batman.Controller
  routingKey: 'lessons'

  show: (options) ->
    # ac = YieldDemo.ArticlesController.get('sharedController')
    ac = @get('articlesController')
    console.log 'ac', ac
    console.log 'alternative', @articlesController
    ac.switchArticle id: options.articleId
    ac.viewLesson id: options.id

  viewLesson: (lesson) ->
    @render into: 'lesson', source: lesson.get('source'), context: @

  render: (options) ->
    return if not options
    view = super
    view.on 'ready', =>
      # Could use @accessor here to @lessons.filter
      @fire 'lessonLoaded'
    view
