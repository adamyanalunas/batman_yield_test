YieldHelper = (source, container, context=new Batman.View) ->
  config = into: container
  config[if source.indexOf('<') isnt -1 then 'html' else 'source'] = source

  context.render config

class @YieldDemo extends Batman.App

  @title = "Batman Yield Views Demo"
  Batman.ViewStore.prefix = 'views'

  # Routes
  @resources 'articles', ->
    @resources 'lessons'
  @resources 'lessons'
  @resources 'main'

  @route 'viewLesson/:lessonId', 'article#viewLesson'
  @route 'article/:articleId/lesson/:lessonId', 'article#viewLesson'

  @root 'main#index'

  @on 'run', ->
    console?.log "Running ...."

  @on 'ready', ->
    console?.log "#{@name} ready for use."

class YieldDemo.Lesson extends Batman.Model
  @classAccessor 'resourceName', -> @name
  @belongsTo 'article'
  @persist Batman.LocalStorage

  @encode 'source', 'name'

class YieldDemo.Article extends Batman.Model
  @classAccessor 'resourceName', -> @name
  @hasMany 'lessons'
  @persist Batman.LocalStorage

  @encode 'content'

class YieldDemo.MainController extends Batman.Controller
  routingKey: 'main'

  constructor: ->
    super
    @articleController = new YieldDemo.ArticleController 'articles'
    @navController = new YieldDemo.NavigatonController

    @clearArticles()
    @loadArticles (articles) =>
      @article = @currentArticle = articles.toArray()[0]

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

        cb?(new Batman.Set(article))

  index: (args) ->
    firstLesson = @currentArticle.get('lessons').toArray()[0]
    firstLesson.set 'active', true
    @articleController.viewLesson firstLesson.get('id')

  showArticle: (article) ->
    lessons = article.get('lessons')

    firstLesson = lessons.toArray()[0]
    firstLesson.set 'active', true
    source = firstLesson.get('source')

    @currentArticle = article
    @articleController.viewArticle source

class YieldDemo.ArticleController extends Batman.Controller
  routingKey: 'article'

  constructor: (options) ->
    @setup options
    super

  setup: (options) ->
    @set 'container', options?.container
    @view = new Batman.View

  viewArticle: (source, container="article") ->
    config = into: @get('container') ? container
    config[if source.indexOf('<') isnt -1 then 'html' else 'source'] = source

    @render config

  viewLesson: (lessonId) ->
    lessonId = {lessonId: lessonId} unless Batman.typeOf(lessonId) is 'Object'
    lesson = YieldDemo.Lesson.find lessonId.lessonId, (err, lesson) =>
      console.error err if err
      @viewArticle lesson.get 'source' if lesson
      # @render lesson.get('source')
      # YieldHelper("articles/#{lesson.get('source')}", 'article', @)

    # @render false

  @::on 'rendered', ->
    console.log 'I HAZ DONE RENDERING'

class YieldDemo.LessonController extends Batman.Controller
  routingKey: 'lessons'

class YieldDemo.NavigatonController extends Batman.Controller
