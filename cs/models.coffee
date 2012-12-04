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
