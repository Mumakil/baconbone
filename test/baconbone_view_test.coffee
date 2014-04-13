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
