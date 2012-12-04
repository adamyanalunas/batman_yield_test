# Batman.config.usePushState = yes
# Batman.config.pathPrefix = '/'

class @YieldDemo extends Batman.App

  @title = "Batman Yield Views Demo"
  Batman.ViewStore.prefix = 'views'

  # Routes
  @resources 'articles', ->
    @resources 'lessons'
  @resources 'lessons'
  @resources 'main'

  @route 'viewLesson/:id', 'main#viewLesson'
  @route 'home', 'main#index'

  @root 'main#index'

  # @on 'run', ->
  #   console?.log "Running ...."

  # @on 'ready', ->
  #   console?.log "#{@name} ready for use."
