class YieldDemo.MainController extends Batman.Controller
  routingKey: 'main'

  constructor: ->
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

class YieldDemo.ArticleController extends Batman.Controller
  routingKey: 'article'

  constructor: (options) ->
    @setup options
    super

  @accessor 'lessons',
    get: ->
      @get('article.lessons')

  setup: (options) ->
    @set 'article', options?.article

  render: ->
    view = super
    view.on 'ready', =>
      @fire 'lessonLoaded'
    view

  viewLesson: (lesson) ->
    YieldDemo.Lesson.get('all').forEach (inactiveLesson) ->
      inactiveLesson.unset 'active'
      # Overwrite given lesson with full lesson data
      if lesson.id and parseInt(lesson.id, 10) == inactiveLesson.get('id')
        lesson = inactiveLesson
    lesson.set 'active', true
    @render into: 'article', source: lesson.get('source')

class YieldDemo.LessonController extends Batman.Controller
  routingKey: 'lessons'

class YieldDemo.NavigatonController extends Batman.Controller
