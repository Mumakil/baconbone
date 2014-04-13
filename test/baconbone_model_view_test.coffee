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
