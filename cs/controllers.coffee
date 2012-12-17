class YieldDemo.MainController extends Batman.Controller
  routingKey: 'main'

  constructor: ->
    # @set 'articlesController', new YieldDemo.ArticlesController
    YieldDemo.ArticlesController.get('sharedController').on 'articleLoaded', (lesson) ->
      console.log 'OHAY, I LOADED LESSON #', lesson.get('id'), ' for article #', lesson.get('article.id')

  index: (args) ->

class YieldDemo.ArticlesController extends Batman.Controller
  # @beforeFilter (options) =>
  #   if options.action == 'show'
  #     @fire 'willShow', options

  # @afterFilter (options) =>
  #   if options.action == 'show'
  #     @fire 'didShow', options

  routingKey: 'articles'

  constructor: (options) ->
    @setup options
    super options

  # @accessor 'lessons',
  #   get: ->
  #     @get('article.lessons')

  # @accessor 'activeLesson',
  #   get: ->
  #     activeLesson = @get('lessons').find (lesson) ->
  #       lesson if lesson.get('active') == true

  #     activeLesson

  setup: (options = {}) ->
    @set 'articles', YieldDemo.Article.get('all')
    @set 'lessonController', options.lessonController
    unless options.lessonController
      lessonController = new YieldDemo.LessonsController
      # lessonController.on 'lessonLoaded', (options) =>
      #   @fire 'articleLoaded', @
      #   YieldDemo.ArticlesController.get('sharedController').fire 'articleLoaded', @

      @set 'lessonController', lessonController

    @

  render: (options) ->
    # return if not options
    view = super
    view.on 'ready', =>
      # @fire 'lessonLoaded', @get('activeLesson')
      @fire 'articleLoaded', @
    view

  index: (options) ->

  show: (options) ->
    @switchArticle options

  reset: ->
    @get('article.lessons').forEach (inactiveLesson) ->
      inactiveLesson.unset 'active'

  viewLesson: (options) ->
    # Loading from the model will break the data binding.
    # Use the current article to preserve binding.
    id = parseInt(options.id, 10)
    lesson = @get('article.lessons').find (findLesson) =>
      @set 'lesson', findLesson if findLesson.get('id') == id

    unless @get('lesson')
      return Batman.redirect '/home'

    @reset()
    lesson.set 'active', true

    # TODO: This is bad
    view = @render into: 'article', source: 'articles/show', context: @
    @get('lessonController').viewLesson lesson

  switchArticle: (options) ->
    id = parseInt(options.id, 10)
    @get('articles').find (article) =>
      @set('article', article) if article.get('id') == id


class YieldDemo.LessonsController extends Batman.Controller
  routingKey: 'lessons'

  setup: (options = {}) ->
    @set 'ac', new YieldDemo.ArticlesController

  show: (options) ->
    ac = @get('ac')
    if ac == undefined
      @setup()
      ac = @get 'ac'
    ac.setup lessonController: @
    ac.switchArticle id: options.articleId
    ac.viewLesson id: options.id

  viewLesson: (lesson) ->
    @render into: 'lesson', source: lesson.get('source'), context: @

  render: (options) ->
    # NOTE: This renders actual lesson show.html if return is removed
    return if not options
    view = super
    view.on 'ready', =>
      # Could use @accessor here to @lessons.filter
      @fire 'lessonLoaded'
    view
