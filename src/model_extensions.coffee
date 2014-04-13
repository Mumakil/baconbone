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
