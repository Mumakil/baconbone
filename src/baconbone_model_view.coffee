# A view class that renders one model
class Baconbone.ModelView extends Baconbone.View

  # Model events get bound automatically like dom events.
  #
  # Example:
  #   {'change:name': 'updateName'}
  modelEvents: undefined

  # Automatic dom bindings so that certain model properties can be bound to
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

  # Render the view as html string.
  #
  #   data - template variables
  #
  # Returns a html string
  template: (data) -> ''

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

  # Renders the view. Usually it's enough to just override this.template or this.data.
  render: ->
    Bacon.once 
    @$el.html @template(@data())
    @
