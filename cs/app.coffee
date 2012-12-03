YieldHelper = (path, container, context=new Batman.View) ->
  # if context is 'hide'
  #   context.html = ''
  #   context.source = ''
  # else
  # console.log context
  # context.render {source: path, into: 'article'}
    # $(".modal").modal()
class @YieldDemo extends Batman.App

  @title = "Batman Yield Views Demo"
  Batman.ViewStore.prefix = 'views'

  # Routes
  @resources 'articles', ->
    @resources 'lessons'
  @resources 'lessons'
  @resources 'main'

  @route 'viewLesson/:lessonId', 'article#viewLesson'

  @root 'main#index'


  # here and below is automatically generated
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

class YieldDemo.MainView extends Batman.View
  constructor: ->
    super
    console.log 'imma view!'

class YieldDemo.LessonController extends Batman.Controller
  routingKey: 'lessons'

  constructor: ->
    console.log 'LessonController loaded'
    super

class YieldDemo.MainController extends Batman.Controller
  routingKey: 'main'

  constructor: ->
    super
    @articleController = new YieldDemo.ArticleController 'articles'
    @navController = new YieldDemo.NavigatonController

    @clearArticles()
    @articles = @loadArticles()
    @article = @articles.toArray()[0]

  clearArticles: ->
    YieldDemo.Article.load (err, articles) ->
      articles?.forEach (article) -> article.destroy()
    YieldDemo.Lesson.load (err, lessons) ->
      lessons?.forEach (lesson) -> lesson.destroy()

  loadArticles: ->
    YieldDemo.Article.load (err, articles) ->
      if not articles?.length
        lesson1 = new YieldDemo.Lesson(source: 'first', name: 'Lesson 1')
        lesson2 = new YieldDemo.Lesson(source: 'second', name: 'Lesson 2')
        lesson3 = new YieldDemo.Lesson(source: 'third', name: 'Lesson 3')
        lesson1.save()
        lesson2.save()
        lesson3.save()

        article = new YieldDemo.Article content: 'I AM THE FIRST ARTICLE'
        article.get('lessons').add lesson1
        article.get('lessons').add lesson2
        article.get('lessons').add lesson3

        article.save()

    YieldDemo.Article.get 'all'

  index: ->
    YieldDemo.Article.find 1, (err, article) =>
      @showArticle(article)

  showArticle: (article) ->
    lessons = article.get('lessons')
    console.log lessons
    firstLesson = lessons.toArray()[0]
    console.log firstLesson

    firstLesson.set 'active', true
    source = firstLesson.get('source')
    @navController.set 'lessons', lessons
    console.log 'len', lessons.length
    # @article = YieldHelper 'articles/first', 'artticle', @
    # @mainView = new YieldDemo.MainView()
    # articleController.dispatch 'viewArticle', 'articles/first'
    # articleController = YieldDemo.ArticleController.get('sharedController')
    @articleController.viewArticle  "articles/#{source}"
    # @shit = 'poop'

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

  viewLesson: ->
    console.log 'viewLesson', arguments

    @render false

  @::on 'rendered', ->
    console.log 'I HAZ DONE RENDERING'

class YieldDemo.NavigatonController extends Batman.Controller
  constructor: ->
    super
    # @render view: new Batman.View( html: "<h2>OHMAN NAV</h2>"), into: 'nav'

