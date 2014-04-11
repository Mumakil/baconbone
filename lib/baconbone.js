
/*
Extend Backbone with bacon functionality
 */

(function() {
  var Backbone, Baconbone, eventExtras, target, targets, _i, _len,
    __slice = [].slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Backbone = window.Backbone;

  targets = [Backbone, Backbone.Events, Backbone.Router.prototype, Backbone.Model.prototype, Backbone.Collection.prototype, Backbone.View.prototype];

  eventExtras = {
    asEventStream: function(event) {
      var eventSource;
      eventSource = this;
      return new Bacon.EventStream(function(sink) {
        var handler, unbind;
        handler = function() {
          var args, reply;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          reply = sink((function(func, args, ctor) {
            ctor.prototype = func.prototype;
            var child = new ctor, result = func.apply(child, args);
            return Object(result) === result ? result : child;
          })(Bacon.Next, args, function(){}));
          if (reply === Bacon.noMore) {
            return unbind();
          }
        };
        unbind = function() {
          return eventSource.off(event, handler);
        };
        eventSource.on(event, handler);
        return unbind;
      });
    },
    takeStream: function(stream) {
      this._end || (this._end = this.asEventStream('dispose'));
      return stream.takeUntil(this._end);
    },
    dispose: function() {
      this.trigger('dispose');
      return delete this._end;
    }
  };

  for (_i = 0, _len = targets.length; _i < _len; _i++) {
    target = targets[_i];
    _.extend(target, eventExtras);
  }

  _.extend(Backbone.Model.prototype, {
    asProperty: function(attribute) {
      if (attribute != null) {
        return this.asEventStream("change:" + attribute).map(this, 'get', attribute).toProperty(this.get(attribute));
      } else {
        return this.asEventStream('change').map(this, 'toJSON').toProperty(this.toJSON());
      }
    }
  });

  window.Baconbone = Baconbone = {};

  Baconbone.View = (function(_super) {
    __extends(View, _super);

    function View() {
      this.findChild = __bind(this.findChild, this);
      this.removeChild = __bind(this.removeChild, this);
      this.addChild = __bind(this.addChild, this);
      this._children = [];
      View.__super__.constructor.apply(this, arguments);
    }

    View.prototype.addChild = function(view) {
      if (!(this._children.indexOf(view) >= 0)) {
        this._children.push(view);
      }
      return view;
    };

    View.prototype.removeChild = function(view) {
      var index, _ref;
      index = this._children.indexOf(view);
      if (index < 0) {
        return;
      }
      [].splice.apply(this._children, [index, index - index + 1].concat(_ref = [])), _ref;
      view.remove();
      return view;
    };

    View.prototype.findChild = function(model) {
      var view, _j, _len1, _ref;
      _ref = this._children;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        view = _ref[_j];
        if (view.model.id === model.id) {
          return view;
        }
      }
    };

    View.prototype.remove = function() {
      var view, _j, _len1, _ref;
      _ref = this._children.slice(0);
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        view = _ref[_j];
        this.removeChild(view);
      }
      this.dispose();
      return View.__super__.remove.apply(this, arguments);
    };

    return View;

  })(Backbone.View);

  Baconbone.ModelView = (function(_super) {
    __extends(ModelView, _super);

    ModelView.prototype.modelEvents = void 0;

    ModelView.prototype.domBindings = void 0;

    function ModelView() {
      var event, handler, property, selector, _ref, _ref1;
      ModelView.__super__.constructor.apply(this, arguments);
      if (this.modelEvents != null) {
        _ref = this.modelEvents;
        for (event in _ref) {
          handler = _ref[event];
          this.bindModelEvent(event, handler);
        }
      }
      if (this.domBindings != null) {
        _ref1 = this.domBindings;
        for (selector in _ref1) {
          property = _ref1[selector];
          this.bindToDom(this.model.asProperty(property), selector);
        }
      }
    }

    ModelView.prototype.data = function() {
      return this.model.toJSON();
    };

    ModelView.prototype.template = function(data) {
      return '';
    };

    ModelView.prototype.bindModelEvent = function(event, handler) {
      var stream;
      stream = this.takeStream(this.model.asEventStream(event));
      if (_.isFunction(handler)) {
        return stream.onValue(handler);
      } else {
        if (!_.isFunction(this[handler])) {
          throw new Error("" + handler + " is not a function");
        }
        return stream.onValue(_.bind(this[handler], this));
      }
    };

    ModelView.prototype.bindToDom = function(property, selector, options) {
      if (options == null) {
        options = {};
      }
      if (_.isFunction(options.transformer)) {
        property = property.map(options.transformer);
      }
      return this.takeStream(property).onValue((function(_this) {
        return function(val) {
          var $el;
          $el = _.isString(selector) ? _this.$(selector) : selector;
          return $el[options.html ? 'html' : 'text'](val);
        };
      })(this));
    };

    ModelView.prototype.render = function() {
      Bacon.once;
      this.$el.html(this.template(this.data()));
      return this;
    };

    return ModelView;

  })(Baconbone.View);

  Baconbone.CollectionView = (function(_super) {
    __extends(CollectionView, _super);

    CollectionView.prototype.collectionEvents = void 0;

    CollectionView.prototype.modelView = Baconbone.ModelView;

    function CollectionView() {
      this.renderChild = __bind(this.renderChild, this);
      var event, handler, _ref;
      CollectionView.__super__.constructor.apply(this, arguments);
      this.rendered = false;
      this.takeStream(this.collection.asEventStream('add')).filter((function(_this) {
        return function() {
          return _this.rendered;
        };
      })(this)).map(this.renderChild).map('.$el').onValue((function(_this) {
        return function($el) {
          return _this.$el.append($el);
        };
      })(this));
      this.takeStream(this.collection.asEventStream('remove')).filter((function(_this) {
        return function() {
          return _this.rendered;
        };
      })(this)).map(this.findChild).filter(_.identity).onValue(this.removeChild);
      this.takeStream(this.collection.asEventStream('reset')).filter((function(_this) {
        return function() {
          return _this.rendered;
        };
      })(this)).onValue((function(_this) {
        return function() {
          var view, _j, _len1, _ref;
          _ref = _this._children.slice(0);
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            view = _ref[_j];
            _this.removeChild(view);
          }
          return _this.render();
        };
      })(this));
      _ref = this.collectionEvents;
      for (event in _ref) {
        handler = _ref[event];
        this.bindCollectionEvent(event, handler);
      }
    }

    CollectionView.prototype.bindCollectionEvent = function(event, handler) {
      var stream;
      stream = this.takeStream(this.collection.asEventStream(event));
      if (_.isFunction(handler)) {
        return stream.onValue(handler);
      } else {
        if (!_.isFunction(this[handler])) {
          throw new Error("" + handler + " is not a function");
        }
        return stream.onValue(_.bind(this[handler], this));
      }
    };

    CollectionView.prototype.renderChild = function(model) {
      var view;
      view = this.addChild(new this.modelView({
        model: model
      }));
      return view.render();
    };

    CollectionView.prototype.render = function() {
      this.rendered = true;
      this.$el.empty().append(this.collection.map((function(_this) {
        return function(model) {
          return _this.renderChild(model).$el;
        };
      })(this)));
      return this;
    };

    return CollectionView;

  })(Baconbone.View);

}).call(this);

//# sourceMappingURL=maps/baconbone.js.map
