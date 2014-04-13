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
