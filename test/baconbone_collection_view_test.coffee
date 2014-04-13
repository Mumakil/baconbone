class SampleModelView extends Baconbone.ModelView
  modelEvents:
    'sampleEvent': 'handleEvent'
  domBindings:
    '#name': 'name'
  handleEvent: ->
    # Trigger event with this context as argument
    @trigger 'eventHandled', this
  renderTemplate: (data) ->
    "<span id='name'>#{data.name}</span><span id='email'>#{data.email}</span>"

class SampleCollectionView extends Baconbone.CollectionView
  collectionEvents:
    'otherEvent': 'handleEvent'
  modelView: SampleModelView
  handleEvent: ->
    # Trigger event with this context as argument
    @trigger 'eventHandled', this

describe 'Baconbone.CollectionView', ->

  beforeEach ->
    @collection = new Backbone.Collection()
    @view = new SampleCollectionView collection: @collection

  describe 'binding to collection events', ->

    beforeEach ->
      @spy = jasmine.createSpy('eventHandler')
      @view.on 'eventHandled', @spy

    afterEach ->
      @view.off 'eventHandler', @spy

    it 'binds to collection event', ->
      @collection.trigger 'otherEvent'
      expect(@spy).toHaveBeenCalled()

  describe 'rendering collection', ->

    lastId = 0

    newModel = ->
      lastId += 1
      new Backbone.Model(id: lastId, name: "name#{lastId}", email: "email#{lastId}")

    beforeEach ->
      @collection.add newModel()
      @view.render()

    it 'renders existing models', ->
      expect(@view.$el.children().length).toBe 1
      expect(@view._children.length).toBe 1

    it 'adds a new model', ->
      @collection.add newModel()
      expect(@view.$el.children().length).toBe 2
      expect(@view._children.length).toBe 2

    it 'removes a view', ->
      @collection.remove @collection.first()
      expect(@view.$el.children().length).toBe 0
      expect(@view._children.length).toBe 0
