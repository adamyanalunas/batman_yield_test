class YieldDemo.ArticleView extends Batman.View
  @::on 'ready', ->
    console.log 'ArticleView reporting for duty'

  # @::on 'rendered', ->
  #   console.log 'ArticleView has rendered'

  @::event('ready').oneShot = false

  constructor: (options) ->
    super

  viewLesson: (lesson) ->
    console.log 'viewLesson', lesson
    # @render source: "#{lesson.get('source')}.html", into: 'article'
    @render source: '<h3>poo pants</h3>', into: 'article'

  ready: ->
    node = @get('node')
    # console.log 'I HAZ NODE', node
    # @set 'content', 'b-holes'
