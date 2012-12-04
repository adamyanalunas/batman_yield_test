class YieldDemo.MainController extends Batman.Controller
  routingKey: 'main'

  constructor: ->
    @articleController = new YieldDemo.ArticleController
    @articleController.on 'lessonLoaded', (lesson) ->
      console.log 'OHAY, I LOADED LESSON #', lesson.get('id'), lesson

    @clearArticles()
    @loadArticles (articles) =>
      @article = @currentArticle = articles.toArray()[0]
      @articleController.set 'article', @article

  renderMain: ->
    @render source: 'main/index', into: 'main', conext: @

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
    @viewLesson id: 1

  viewLesson: (options) ->
    @renderMain()
    @currentArticle.get('lessons').forEach (lesson) =>
      # This is implementation-specific
      if lesson.get('id') == parseInt(options.id, 10)
        @articleController.viewLesson lesson

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

  render: ->
    view = super
    view.on 'ready', =>
      # Could use @accessor here to @lessons.filter
      @fire 'lessonLoaded', @get('activeLesson')
    view

  viewLesson: (lesson) ->
    @get('lessons').forEach (inactiveLesson) ->
      inactiveLesson.unset 'active'
    lesson.set 'active', true
    # This could be moved to an @accessor
    @set 'activeLesson', lesson
    @render into: 'article', source: lesson.get('source'), context: @
