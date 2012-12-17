# Batman.config.usePushState = yes
# Batman.config.pathPrefix = '/'

class @YieldDemo extends Batman.App

  @title = "Batman Yield Views Demo"
  Batman.ViewStore.prefix = 'views'

  # Routes
  # TODO: Build custom route to replace all @resource routes
  @resources 'articles', ->
    @resources 'lessons'
  @resources 'main'

  # @route 'home', 'main#index'

  @root 'main#index'

  # @on 'run', ->
  #   console?.log "Running ...."

  @::clearArticles = ->
    YieldDemo.Lesson.load (err, lessons) ->
      lessons?.forEach (lesson) -> lesson.destroy()
    YieldDemo.Article.load (err, articles) ->
      articles?.forEach (article) -> article.destroy()

  # Substitute this with calls to a real db
  @::loadArticles = (cb) ->
    YieldDemo.Article.load (err, articles) ->
      if not articles?.length
        console.log 'Initial data creation'
        dogArticle = YieldDemo.Article::generateDogArticle()
        catArticle = YieldDemo.Article::generateCatArticle()

    all = YieldDemo.Article.get('all')
    cb?(all)

    all.sortedBy('id', 'asc')

  @on 'ready', ->
    @set 'articles', @::loadArticles()
    # console?.log "#{@name} ready for use."
