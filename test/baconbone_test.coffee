window.Helper = {}

class Helper.SampleCollectionView extends Baconbone.CollectionView
  collectionEvents:
    'otherEvent': 'handleEvent'
  modelView: Helper.SampleModelView
  handleEvent: ->
    # Trigger event with this context as argument
    @trigger 'eventHandled', this
