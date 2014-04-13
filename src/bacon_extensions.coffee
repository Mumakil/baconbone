###
Extend Backbone with bacon functionality
###

Backbone = window.Backbone

targets = [
  Backbone
  Backbone.Events
  Backbone.Router::
  Backbone.Model::
  Backbone.Collection::
  Backbone.View::
]

eventExtras =
  # A stream of events.
  #   event - Events to stream, can be anything
  #     Backbone.Events.on understands
  # Returns an EventStream
  asEventStream: (event) ->
    eventSource = @
    new Bacon.EventStream (sink) ->
      handler = (args...) ->
        reply = sink(new Bacon.Next args...)
        if reply == Bacon.noMore
          unbind()
      unbind = ->
        eventSource.off(event, handler)
      eventSource.on(event, handler)
      unbind

  # Alternative to the above: Returns a stream that
  # end automatically when the view is disposed of 
  takeStream: (stream) ->
    @_end ||= @asEventStream('dispose')
    stream.takeUntil(@_end)

  # Dispose of all the added stream handlers
  dispose: ->
    @trigger('dispose')
    delete @_end

# Extend Backbone.Events and all BB classes individually
# because Events has already been mixed into them
_.extend target, eventExtras for target in targets