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

  # @on 'run', ->
  #   console?.log "Running ...."

  # @on 'ready', ->
  #   console?.log "#{@name} ready for use."
