class YieldDemo.ArticleView extends Batman.View
  @::on 'ready', ->
    console.log 'ArticleView reporting for duty'

  # @::on 'rendered', ->
  #   console.log 'ArticleView has rendered'

  @::event('ready').oneShot = false

  constructor: (options) ->
    super

  viewLesson: (lesson) ->
    @_rendered = false
    console.log 'viewLesson', lesson
    # @render source: "#{lesson.get('source')}.html", into: 'article'
    @render

  render: ->
    super

  ready: ->
    node = @get('node')
    # console.log 'I HAZ NODE', node
    # @set 'content', 'b-holes'
