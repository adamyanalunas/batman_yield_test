class YieldDemo.MainController extends Batman.Controller
  routingKey: 'main'

  constructor: ->
    # @articleController = new YieldDemo.ArticleController container: 'articles'
    @articleController = new YieldDemo.ArticleController
    @navController = new YieldDemo.NavigatonController

    @clearArticles()
    @loadArticles (articles) =>
      @article = @currentArticle = articles.toArray()[0]
      @articleController.set 'article', @article

  clearArticles: ->
    YieldDemo.Article.load (err, articles) ->
      articles?.forEach (article) -> article.destroy()
    YieldDemo.Lesson.load (err, lessons) ->
      lessons?.forEach (lesson) -> lesson.destroy()

  loadArticles: (cb) ->
    allArticles = null
    YieldDemo.Article.load (err, articles) ->
      if not articles?.length
        lesson1 = new YieldDemo.Lesson(source: 'lessons/first', name: 'Lesson 1')
        lesson2 = new YieldDemo.Lesson(source: 'lessons/second', name: 'Lesson Two')
        lesson3 = new YieldDemo.Lesson(source: 'lessons/third', name: 'Lesson C')
        lesson1.save()
        lesson2.save()
        lesson3.save()

        article = new YieldDemo.Article content: 'I AM THE FIRST ARTICLE'
        article.get('lessons').add lesson1
        article.get('lessons').add lesson2
        article.get('lessons').add lesson3
        # article.save()

        cb?(new Batman.Set(article))

  index: (args) ->
    firstLesson = @currentArticle.get('lessons').toArray()[0]
    @articleController.viewLesson firstLesson
    return false

  ready: ->
    console.log 'big daddy is ready'
  # showArticle: (article) ->
  #   lessons = article.get('lessons')

  #   firstLesson = lessons.toArray()[0]
  #   firstLesson.set 'active', true
  #   source = firstLesson.get('source')

  #   @currentArticle = article
  #   YieldDemo.YieldHelper(source, 'article', @articleController)

class YieldDemo.ArticleController extends Batman.Controller
  routingKey: 'article'

  constructor: (options) ->
    @setup options
    super
    # view = @render()
    # view.on 'ready', =>
    #   console.log 'article view is ready?'

  @accessor 'lessons',
    get: ->
      @get('article.lessons')

  setup: (options) ->
    # @set 'container', options?.container
    @set 'article', options?.article
    # @prepLesson()

  # prepLesson: ->
  #   @articleView = new YieldDemo.ArticleView
  #   @articleView.on 'lessonLoaded', (renderedLesson) =>

  render: ->
    view = super
    console.log 'rendering ', view
    view.on 'ready', =>
      console.log 'reeeaaddy'
      @fire 'lessonLoaded'
    view

  viewLesson: (lesson) ->
    @get('lessons').forEach (inactiveLesson) ->
      inactiveLesson.unset 'active'
    lesson.set 'active', true
    @view = @render into: 'article', source: lesson.get('source')

  # viewLessonOld: (lesson) ->
  #   @articleView.set 'node', $('article').get(0)
  #   @articleView.viewLesson lesson
  #   @get('lessons').forEach (inactiveLesson) ->
  #     inactiveLesson.unset 'active'
  #   lesson.set 'active', true

  # @::on 'ready  ', ->
  #   console.log 'I HAZ DONE RENDERING'

class YieldDemo.LessonController extends Batman.Controller
  routingKey: 'lessons'

class YieldDemo.NavigatonController extends Batman.Controller
