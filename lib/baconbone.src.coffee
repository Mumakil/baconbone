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
    Bacon.fromBinder (sink) ->
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
_.extend Backbone.Model::,

  # Returns a Bacon.Property of a model attribute
  #   attribute - The name of the attribute to track. If empty,
  #     the returned property will contain all model's attributes
  asProperty: (attribute) ->
    if attribute?
      @asEventStream("change:#{attribute}")
        .map(@, 'get', attribute).toProperty(@get(attribute))
    else
      @asEventStream('change').map(@, 'toJSON').toProperty(@toJSON())

window.Baconbone = Baconbone = {}
# A basic view class that provides some hierarchy
class Baconbone.View extends Backbone.View

  constructor: ->
    @_children = []
    super

  # Adds a child view
  #
  #   view - View that should be destroyed when this view is removed
  #
  # Returns the same view
  addChild: (view) =>
    @_children.push view unless @_children.indexOf(view) >= 0
    view

  # Removes a previously registered child view and remove()s it
  #
  #   view - view to be removed
  #
  # Returns the view
  removeChild: (view) =>
    index = @_children.indexOf view
    return if index < 0
    @_children[index..index] = []
    view.remove()
    view

  # Find a child view based on a model or check if view is registered
  # as child view
  #
  #   model - a model to look for in the views
  #
  # Returns the first view that has the model
  findChild: (modelOrView) =>
    return modelOrView if @_children.indexOf(modelOrView) >= 0
    return view for view in @_children when view.model.id is modelOrView.id

  # Removes the view and all its children.
  remove: ->
    @removeChild(view) for view in @_children.slice(0)
    @dispose()
    super

# A view class that renders one model
class Baconbone.ModelView extends Baconbone.View

  # Model events get bound automatically like dom events.
  #
  # Example:
  #   {'change:name': 'updateName'}
  modelEvents: undefined

  # Automatic dom binding so that certain model properties can be bound to
  # selectors. This means that whenever the model changes, the selctor's contents
  # gets updated.
  #
  # Example:
  #   {'#name': 'name'}
  domBindings: undefined

  constructor: ->
    super
    @bindModelEvent event, handler for event, handler of @modelEvents if @modelEvents?
    @bindToDom @model.asProperty(property), selector for selector, property of @domBindings if @domBindings?

  # Returns the data for the template. Override for more complex behavior
  # than the default model.toJSON()
  data: ->
    @model.toJSON()

  # Render the view as html string. Override for your use case.
  #
  #   data - template variables
  #
  # Returns a html string
  renderTemplate: (data) -> ''

  # Binds an event handler to a model event.
  #
  #   event - model event to bind to
  #   handler - name of the event handler or a function
  bindModelEvent: (event, handler) ->
    stream = @takeStream(@model.asEventStream(event))
    if _.isFunction handler
      stream.onValue handler
    else
      throw new Error("#{handler} is not a function") unless _.isFunction @[handler]
      stream.onValue _.bind @[handler], @

  # Binds a property to dom so that when the property changes, the html gets updated
  #
  #   property - a Bacon.Property
  #   selector - a selector or a jquery object
  #   options - options hash (optional)
  #     html - set to true to use .html() instead of .text() to update the dom
  #     transformer - maps the property's value through a transforming function
  bindToDom: (property, selector, options = {}) ->
    property = property.map(options.transformer) if _.isFunction options.transformer
    @takeStream(property).onValue (val) =>
      $el = if _.isString(selector) then @$(selector) else selector
      $el[if options.html then 'html' else 'text'](val)

  # Renders the view. Usually it's enough to just override this.renderTemplate or this.data
  # or use before:render and after:render events.
  render: ->
    @trigger('before:render')
    @$el.html @renderTemplate(@data())
    @trigger('after:render')
    @

# A view class that renders a collection
class Baconbone.CollectionView extends Baconbone.View

  # Automatically bound collection events
  collectionEvents: undefined

  # Render one of this view class for each model
  modelView: Baconbone.ModelView

  constructor: ->
    super
    @rendered = false
    # Automatically render views when they are added
    @takeStream(@collection.asEventStream('add'))
      .filter(=> @rendered)
      .map(@renderChild)
      .map('.$el')
      .onValue ($el) =>
        @$el.append($el)
    # Remove views when models are removed from collection
    @takeStream(@collection.asEventStream('remove'))
      .filter(=> @rendered)
      .map(@findChild)
      .filter(_.identity)
      .onValue(@removeChild)
    # Remove all views and rerender
    @takeStream(@collection.asEventStream('reset'))
      .filter(=> @rendered)
      .onValue =>
        @removeChild view for view in @_children.slice(0)
        @render()
    @bindCollectionEvent event, handler for event, handler of @collectionEvents

  # Binds a handler to a collection event
  #
  #   event - collection event to bind to
  #   handler - name of the event handler or a function
  bindCollectionEvent: (event, handler) ->
    stream = @takeStream @collection.asEventStream(event)
    if _.isFunction handler
      stream.onValue handler
    else
      throw new Error("#{handler} is not a function") unless _.isFunction @[handler]
      stream.onValue _.bind @[handler], @

  # Renders a child view when given a model.
  renderChild: (model) =>
    view = @addChild new @modelView(model: model)
    view.render()

  render: ->
    @rendered = true
    @$el.empty().append @collection.map (model) =>
      @renderChild(model).$el
    @
