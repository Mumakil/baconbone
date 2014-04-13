window.Helper = {}

class Helper.SampleCollectionView extends Baconbone.CollectionView
  collectionEvents:
    'otherEvent': 'handleEvent'
  modelView: Helper.SampleModelView
  handleEvent: ->
    # Trigger event with this context as argument
    @trigger 'eventHandled', this

describe 'Backbone.Events', ->

  describe '#asEventStream', ->

    beforeEach ->
      @obj = _.extend {}, Backbone.Events

    it 'adds a subscriber', ->
      stream = @obj.asEventStream('foo')
      expect(stream).toBeTruthy()
      spy = jasmine.createSpy()
      stream.onValue(spy)
      @obj.trigger('foo', 'bar')
      expect(spy).toHaveBeenCalledWith('bar')

    it 'unsubscribes when calling unsubscribe', ->
      spy = jasmine.createSpy()
      unsubscriber = @obj.asEventStream('foo').onValue(spy)
      expect(typeof unsubscriber).toBe 'function'
      unsubscriber()
      @obj.trigger 'foo'
      expect(spy).not.toHaveBeenCalled()

    it 'does not contain other events', ->
      spy = jasmine.createSpy()
      unsubscribe = @obj.asEventStream('foo').onValue(spy)
      @obj.trigger 'bar'
      expect(spy).not.toHaveBeenCalled()

  describe 'mixing in asEventSteream', ->

    subjects = {
      'Backbone': Backbone,
      'Backbone.Events': Backbone.Events,
      'Backbone.Router': Backbone.Router::,
      'Backbone.Model': Backbone.Model::,
      'Backbone.Collection': Backbone.Collection::,
      'Backbone.View': Backbone.View::
    }
    
    for name, subject of subjects
      
      it "mixes extensions into #{name}", ->
        expect(_.isFunction subject.asEventStream).toBe true
        expect(_.isFunction subject.takeStream).toBe true
        expect(_.isFunction subject.dispose).toBe true
describe 'Backbone.Model', ->

  describe '#asProperty', ->

    beforeEach ->
      @model = new Backbone.Model foo: 'bar'

    it 'creates a property', ->
      prop = @model.asProperty('foo')
      expect(prop instanceof Bacon.Property).toBe true

    it 'has initial value', ->
      spy = jasmine.createSpy()
      @model.asProperty('foo').onValue(spy)
      expect(spy).toHaveBeenCalledWith 'bar'

    it 'triggers events on changes', ->
      spy = jasmine.createSpy()
      @model.asProperty('foo').onValue(spy)
      @model.set foo: 'bazinga'
      expect(spy.calls.count()).toBe 2
      expect(spy).toHaveBeenCalledWith('bazinga')

    it 'tracks all attributes without arguments', ->
      spy = jasmine.createSpy()
      @model.asProperty().onValue(spy)
      expect(spy).toHaveBeenCalledWith foo: 'bar'
      @model.set bar: 'baz'
      expect(spy).toHaveBeenCalledWith foo: 'bar', bar: 'baz'
      @model.set foo: 'bazinga'
      expect(spy).toHaveBeenCalledWith foo: 'bazinga', bar: 'baz'
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

describe 'Baconbone.ModelView', ->

  beforeEach ->
    @model = new Backbone.Model(name: 'name', email: 'email')
    @view = new SampleModelView(model: @model)

  describe 'rendering', ->

    beforeEach ->
      @view.render()

    it 'renders automatically based on template and data', ->
      expect(@view.$('#name').text()).toBe @model.get('name')
      expect(@view.$('#email').text()).toBe @model.get('email')

  describe 'model events', ->

    beforeEach ->
      @spy = jasmine.createSpy('eventHandler')
      @view.on 'eventHandled', @spy

    afterEach ->
      @view.off 'eventHandled', @spy

    it 'binds to model events with proper context', ->
      @model.trigger 'sampleEvent'
      expect(@spy).toHaveBeenCalledWith(@view)

    it 'binds to plain functions', ->
      spy = jasmine.createSpy('otherEventHandler')
      @view.bindModelEvent('otherEvent', spy)
      @model.trigger 'otherEvent'
      expect(spy).toHaveBeenCalled()

  describe 'dom binding', ->

    beforeEach ->
      @view.render()

    it 'updates the view html when model changes', ->
      @model.set name: 'new name'
      expect(@view.$('#name').text()).toBe 'new name'

    it 'handles a more complex dom binding with html and transformation', ->
      $el = @view.$('#email')
      @view.bindToDom @model.asProperty('email'), $el,
        html: true,
        transformer: (email) ->
          "<a href='mailto:#{email}'>#{email}</a>"
      @model.set email: 'john.doe@example.com'
      expect($el.find('a').length).toBe 1
      expect($el.find('a').text()).toBe 'john.doe@example.com'

describe 'Baconbone.View', ->

  beforeEach ->
    @view = new Baconbone.View()
    @otherView = new Baconbone.View()

  describe '#addChild', ->

    beforeEach ->
      @view.addChild @otherView

    it 'adds a child', ->
      expect(@view._children.length).toBe 1
      expect(@view._children).toContain @otherView

    it 'does not add same view twice', ->
      @view.addChild @otherView
      expect(@view._children.length).toBe 1

  describe '#removeChild', ->

    beforeEach ->
      spyOn @otherView, 'remove'
      @view.addChild new Baconbone.View()
      @view.addChild @otherView
      @view.addChild new Baconbone.View()
      @view.removeChild @otherView

    it 'removes an existing view', ->
      expect(@view._children.length).toBe 2
      expect(@view._children).not.toContain @otherView

    it 'calls remove() on child view', ->
      expect(@otherView.remove).toHaveBeenCalled()

    it 'does nothing to an unknown view', ->
      @view.removeChild new Baconbone.View()
      expect(@view._children.length).toBe 2

  describe '#findChild', ->

    beforeEach ->
      @model = new Backbone.Model(id: 1)
      @otherModel = new Backbone.Model(id: 2)
      @view.addChild new Baconbone.View(model: @model)
      @view.addChild new Baconbone.View(model: @otherModel)

    it 'finds a view based on model', ->
      expect(@view.findChild(@model).model).toBe @model
      
    it 'returns the view if passed a child', ->
      view = @view.addChild new Baconbone.View()
      expect(@view.findChild(view)).toBe view

    it 'returns undefined if a view is not found', ->
      expect(@view.findChild(new Backbone.Model(id: 3))).toBeUndefined()
      expect(@view.findChild(new Baconbone.View())).toBeUndefined()

  describe '#remove', ->

    beforeEach ->
      @view.addChild @otherView
      spyOn @view, 'dispose'
      spyOn @otherView, 'remove'
      @view.remove()

    it 'removes subviews', ->
      expect(@otherView.remove).toHaveBeenCalled()

    it 'disposes of streams', ->
      expect(@view.dispose).toHaveBeenCalled()
