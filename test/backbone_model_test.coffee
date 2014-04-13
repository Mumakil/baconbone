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