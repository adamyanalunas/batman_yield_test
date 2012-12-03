// Generated by CoffeeScript 1.4.0
(function() {
  var YieldHelper,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  YieldHelper = function(path, container, context) {
    if (context == null) {
      context = new Batman.View;
    }
  };

  this.YieldDemo = (function(_super) {

    __extends(YieldDemo, _super);

    function YieldDemo() {
      return YieldDemo.__super__.constructor.apply(this, arguments);
    }

    YieldDemo.title = "Batman Yield Views Demo";

    Batman.ViewStore.prefix = 'views';

    YieldDemo.resources('articles', function() {
      return this.resources('lessons');
    });

    YieldDemo.resources('lessons');

    YieldDemo.resources('main');

    YieldDemo.route('viewLesson/:lessonId', 'article#viewLesson');

    YieldDemo.root('main#index');

    YieldDemo.on('run', function() {
      return typeof console !== "undefined" && console !== null ? console.log("Running ....") : void 0;
    });

    YieldDemo.on('ready', function() {
      return typeof console !== "undefined" && console !== null ? console.log("" + this.name + " ready for use.") : void 0;
    });

    return YieldDemo;

  })(Batman.App);

  YieldDemo.Lesson = (function(_super) {

    __extends(Lesson, _super);

    function Lesson() {
      return Lesson.__super__.constructor.apply(this, arguments);
    }

    Lesson.classAccessor('resourceName', function() {
      return this.name;
    });

    Lesson.belongsTo('article');

    Lesson.persist(Batman.LocalStorage);

    Lesson.encode('source', 'name');

    return Lesson;

  })(Batman.Model);

  YieldDemo.Article = (function(_super) {

    __extends(Article, _super);

    function Article() {
      return Article.__super__.constructor.apply(this, arguments);
    }

    Article.classAccessor('resourceName', function() {
      return this.name;
    });

    Article.hasMany('lessons');

    Article.persist(Batman.LocalStorage);

    Article.encode('content');

    return Article;

  })(Batman.Model);

  YieldDemo.MainView = (function(_super) {

    __extends(MainView, _super);

    function MainView() {
      MainView.__super__.constructor.apply(this, arguments);
      console.log('imma view!');
    }

    return MainView;

  })(Batman.View);

  YieldDemo.LessonController = (function(_super) {

    __extends(LessonController, _super);

    LessonController.prototype.routingKey = 'lessons';

    function LessonController() {
      console.log('LessonController loaded');
      LessonController.__super__.constructor.apply(this, arguments);
    }

    return LessonController;

  })(Batman.Controller);

  YieldDemo.MainController = (function(_super) {

    __extends(MainController, _super);

    MainController.prototype.routingKey = 'main';

    function MainController() {
      MainController.__super__.constructor.apply(this, arguments);
      this.articleController = new YieldDemo.ArticleController('articles');
      this.navController = new YieldDemo.NavigatonController;
      this.clearArticles();
      this.articles = this.loadArticles();
      this.article = this.articles.toArray()[0];
    }

    MainController.prototype.clearArticles = function() {
      YieldDemo.Article.load(function(err, articles) {
        return articles != null ? articles.forEach(function(article) {
          return article.destroy();
        }) : void 0;
      });
      return YieldDemo.Lesson.load(function(err, lessons) {
        return lessons != null ? lessons.forEach(function(lesson) {
          return lesson.destroy();
        }) : void 0;
      });
    };

    MainController.prototype.loadArticles = function() {
      YieldDemo.Article.load(function(err, articles) {
        var article, lesson1, lesson2, lesson3;
        if (!(articles != null ? articles.length : void 0)) {
          lesson1 = new YieldDemo.Lesson({
            source: 'first',
            name: 'Lesson 1'
          });
          lesson2 = new YieldDemo.Lesson({
            source: 'second',
            name: 'Lesson 2'
          });
          lesson3 = new YieldDemo.Lesson({
            source: 'third',
            name: 'Lesson 3'
          });
          lesson1.save();
          lesson2.save();
          lesson3.save();
          article = new YieldDemo.Article({
            content: 'I AM THE FIRST ARTICLE'
          });
          article.get('lessons').add(lesson1);
          article.get('lessons').add(lesson2);
          article.get('lessons').add(lesson3);
          return article.save();
        }
      });
      return YieldDemo.Article.get('all');
    };

    MainController.prototype.index = function() {
      var _this = this;
      return YieldDemo.Article.find(1, function(err, article) {
        return _this.showArticle(article);
      });
    };

    MainController.prototype.showArticle = function(article) {
      var firstLesson, lessons, source;
      lessons = article.get('lessons');
      console.log(lessons);
      firstLesson = lessons.toArray()[0];
      console.log(firstLesson);
      firstLesson.set('active', true);
      source = firstLesson.get('source');
      this.navController.set('lessons', lessons);
      console.log('len', lessons.length);
      return this.articleController.viewArticle("articles/" + source);
    };

    return MainController;

  })(Batman.Controller);

  YieldDemo.ArticleController = (function(_super) {

    __extends(ArticleController, _super);

    ArticleController.prototype.routingKey = 'article';

    function ArticleController(options) {
      this.setup(options);
      ArticleController.__super__.constructor.apply(this, arguments);
    }

    ArticleController.prototype.setup = function(options) {
      this.set('container', options != null ? options.container : void 0);
      return this.view = new Batman.View;
    };

    ArticleController.prototype.viewArticle = function(source, container) {
      var config, _ref;
      if (container == null) {
        container = "article";
      }
      config = {
        into: (_ref = this.get('container')) != null ? _ref : container
      };
      config[source.indexOf('<') !== -1 ? 'html' : 'source'] = source;
      return this.render(config);
    };

    ArticleController.prototype.viewLesson = function() {
      console.log('viewLesson', arguments);
      return this.render(false);
    };

    ArticleController.prototype.on('rendered', function() {
      return console.log('I HAZ DONE RENDERING');
    });

    return ArticleController;

  })(Batman.Controller);

  YieldDemo.NavigatonController = (function(_super) {

    __extends(NavigatonController, _super);

    function NavigatonController() {
      NavigatonController.__super__.constructor.apply(this, arguments);
    }

    return NavigatonController;

  })(Batman.Controller);

}).call(this);
