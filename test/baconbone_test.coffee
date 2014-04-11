class SampleModelView extends Baconbone.ModelView
  modelEvents:
    'sampleEvent': 'handleEvent'
  domBindings:
    '#name': 'name'
  handleEvent: ->
    # Trigger event with this context as argument
    @trigger 'eventHandled', this
  template: (data) ->
    "<span id='name'>#{data.name}</span><span id='email'>#{data.email}</span>"

class SampleCollectionView extends Baconbone.CollectionView
  collectionEvents:
    'otherEvent': 'handleEvent'
  modelView: SampleModelView
  handleEvent: ->
    # Trigger event with this context as argument
    @trigger 'eventHandled', this

describe 'Baconbone.js', ->

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

  describe 'Backbone.Model', ->

    it 'should have asEventStream', ->
      expect(_.isFunction Backbone.Model::asEventStream).toBe true

    describe '#asProperty', ->

      beforeEach ->
        @model = new Backbone.Model foo: 'bar'

      it 'creates a property', ->
        prop = @model.asProperty('foo')
        expect(prop).toBeAInstanceOf Bacon.Property

      it 'should have the initial value', ->
        spy = jasmine.createSpy()
        unsubscribe = @model.asProperty('foo').onValue(spy)
        expect(spy).toHaveBeenCalledWith 'bar'

      it 'should trigger events on changes', ->
        spy = jasmine.createSpy()
        unsubscribe = @model.asProperty('foo').onValue(spy)
        @model.set foo: 'bazinga'
        expect(spy.calls.length).toBe 2
        expect(spy.calls[1].args[0]).toBe 'bazinga'

      it 'should track model.attributes without arguments', ->
        spy = jasmine.createSpy()
        unsubscribe = @model.asProperty().onValue(spy)
        expect(spy).toHaveBeenCalledWith foo: 'bar'
        @model.set bar: 'baz'
        expect(spy).toHaveBeenCalledWith foo: 'bar', bar: 'baz'
        @model.set foo: 'bazinga'
        expect(spy).toHaveBeenCalledWith foo: 'bazinga', bar: 'baz'

  describe 'Backbone.Collection', ->

    it 'should have asEventStream', ->
      expect(_.isFunction Backbone.Collection::asEventStream).toBe true

  describe 'Baconbone.View', ->

    beforeEach ->
      @view = new Baconbone.View()
      @otherView = new Baconbone.View()

    describe '#addChild', ->

      beforeEach ->
        @view.addChild @otherView

      it 'should add a child', ->
        expect(@view._children.length).toBe 1
        expect(@view._children).toContain @otherView

      it 'shold not add same view twice', ->
        @view.addChild @otherView
        expect(@view._children.length).toBe 1

    describe '#removeChild', ->

      beforeEach ->
        spyOn @otherView, 'remove'
        @view.addChild new Baconbone.View()
        @view.addChild @otherView
        @view.addChild new Baconbone.View()
        @view.removeChild @otherView

      it 'should remove an existing view', ->
        expect(@view._children.length).toBe 2
        expect(@view._children).not.toContain @otherView

      it 'should call remove for child view', ->
        expect(@otherView.remove).toHaveBeenCalled()

      it 'should handle an unknown view', ->
        @view.removeChild new Baconbone.View()
        expect(@view._children.length).toBe 2

    describe '#findChild', ->

      beforeEach ->
        @model = new Backbone.Model(id: 1)
        @otherModel = new Backbone.Model(id: 2)
        @view.addChild new Baconbone.View(model: @model)
        @view.addChild new Baconbone.View(model: @otherModel)

      it 'should find a view based on model', ->
        expect(@view.findChild(@model).model).toBe @model

      it 'should return undefined if a view is not found', ->
        expect(@view.findChild(new Backbone.Model(id: 3))).not.toBeDefined()

    describe '#remove', ->

      beforeEach ->
        @view.addChild @otherView
        spyOn @view, 'dispose'
        spyOn @otherView, 'remove'
        @view.remove()

      it 'should remove subviews', ->
        expect(@otherView.remove).toHaveBeenCalled()

      it 'should dispose of streams', ->
        expect(@view.dispose).toHaveBeenCalled()

  describe 'Baconbone.ModelView', ->

    beforeEach ->
      @model = new Backbone.Model(name: 'name', email: 'email')
      @view = new SampleModelView(model: @model)

    describe 'rendering', ->

      beforeEach ->
        @view.render()

      it 'should render automatically based on template and data', ->
        expect(@view.$('#name').text()).toBe @model.get('name')
        expect(@view.$('#email').text()).toBe @model.get('email')

    describe 'model events', ->

      beforeEach ->
        @spy = jasmine.createSpy('eventHandler')
        @view.on 'eventHandled', @spy

      afterEach ->
        @view.off 'eventHandled', @spy

      it 'should bind to model events with proper context', ->
        @model.trigger 'sampleEvent'
        expect(@spy).toHaveBeenCalledWith(@view)

      it 'should bind to plain functions', ->
        spy = jasmine.createSpy('otherEventHandler')
        @view.bindModelEvent('otherEvent', spy)
        @model.trigger 'otherEvent'
        expect(spy).toHaveBeenCalled()

    describe 'dom binding', ->

      beforeEach ->
        @view.render()

      it 'should update the view when model changes', ->
        @model.set name: 'new name'
        expect(@view.$('#name').text()).toBe 'new name'

      it 'should handle a more complex dom binding', ->
        $el = @view.$('#email')
        @view.bindToDom @model.asProperty('email'), $el,
          html: true,
          transformer: (email) ->
            "<a href='mailto:#{email}'>#{email}</a>"
        @model.set email: 'john.doe@example.com'
        expect($el.find('a').length).toBe 1
        expect($el.find('a').text()).toBe 'john.doe@example.com'

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
        
      it 'should bind to collection event', ->
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
        
      it 'should render existing models', ->
        expect(@view.$el.children().length).toBe 1
        expect(@view._children.length).toBe 1
        
      it 'should add a new model', ->
        @collection.add newModel()
        expect(@view.$el.children().length).toBe 2
        expect(@view._children.length).toBe 2
        
      it 'should remove a view', ->
        @collection.remove @collection.first()
        expect(@view.$el.children().length).toBe 0
        expect(@view._children.length).toBe 0