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