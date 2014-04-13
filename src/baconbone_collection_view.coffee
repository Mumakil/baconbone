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
