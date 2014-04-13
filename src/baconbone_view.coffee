# A basic view class that provides some hierarchy
class Baconbone.View extends Backbone.View

  constructor: ->
    @_children = []
    super

  # Adds a child view to be automatically destroyed along this
  # view
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

  # Find a subview based on a model
  #
  #   model - a model to look for in the views
  #
  # Returns the first view that has the model
  findChild: (model) =>
    return view for view in @_children when view.model.id == model.id

  # Removes the view and all its children.
  remove: ->
    @removeChild(view) for view in @_children.slice(0)
    @dispose()
    super
