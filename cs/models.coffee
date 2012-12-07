class YieldDemo.Lesson extends Batman.Model
  @classAccessor 'resourceName', -> @name
  @primaryKey: '_id'
  @belongsTo 'article'
  @persist Batman.LocalStorage

  @encode 'source', 'name'

  @::generateDogs = ->
    lesson1 = new Lesson(source: 'lessons/first', name: 'Lesson 1')
    lesson2 = new Lesson(source: 'lessons/second', name: 'Lesson Second')
    lesson3 = new Lesson(source: 'lessons/third', name: 'Lesson C')
    lesson1.save()
    lesson2.save()
    lesson3.save()

    [lesson1, lesson2, lesson3]

  @::generateCats = ->
    lesson1 = new Lesson(source: 'lessons/cat1', name: 'Feline Lesson One')
    lesson2 = new Lesson(source: 'lessons/cat2', name: 'Feline Lesson Two')
    lesson3 = new Lesson(source: 'lessons/cat3', name: 'Feline Lesson Three')
    lesson4 = new Lesson(source: 'lessons/cat4', name: 'Feline Lesson Four')
    lesson1.save()
    lesson2.save()
    lesson3.save()
    lesson4.save()

    [lesson1, lesson2, lesson3, lesson4]

class YieldDemo.Article extends Batman.Model
  @classAccessor 'resourceName', -> @name
  @hasMany 'lessons'
  @primaryKey: '_id'
  @persist Batman.LocalStorage

  @encode 'content'

  @::generateDogArticle = ->
    dogLessons = YieldDemo.Lesson::generateDogs()
    dogArticle = new Article(
      type: 'dog'
      title: 'DOGZ RULE CATS DRULE!'
      lessons: dogLessons
      blurb: 'Talk about dogs'
    )
    dogArticle.save()

    dogArticle

  @::generateCatArticle = ->
    catLessons = YieldDemo.Lesson::generateCats()
    catArticle = new YieldDemo.Article(
      type: 'cat'
      title: 'Cats, clearly, are superior'
      lessons: catLessons
      blurb: 'Talk about cats'
    )
    catArticle.save()

    catArticle

