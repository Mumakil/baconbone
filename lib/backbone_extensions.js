
/*
Extend Backbone with bacon functionality
 */

(function() {
  var Backbone, eventExtras, target, targets, _i, _len,
    __slice = [].slice;

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

}).call(this);

//# sourceMappingURL=maps/backbone_extensions.js.map
