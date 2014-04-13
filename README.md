# Baconbone

Baconbone is built to act as a thin boilerplate on top of Backbone using Bacon.js, to make dealing with events and hierarchy a bit nicer. Why? Some of this is stuff we actually use at [Flowdock](https://www.flowdock.com) and some of this is just something I've considered useful. 

## Examples

### Core functionality

The core functionality is built by extending Backbone event functionality with `.asEventStream()`. This works exactly like Bacon.js's own `$('foo').asEventStream()`. So, everywhere `Backbone.Events` is usable, you can also get a Bacon event stream. Example

Example:
```coffeescript
Backbone.asEventStream('initialized')
  .onValue(-> console.log('Yay! Initialized!'))
# prints 'Yay! Initialized!' to log when Backbone object triggers initialized-event
```

`Backbone.Model` has an additional `.asProperty()`, that can be used to track model's attributes. If given an attribute name as a parameter, the property will always hold that attribute's value, otherwise it will hold what `model.toJSON()` will return.

Example:
```coffeescript
m = new Backbone.Model foo: 'bar'
m.asProperty('foo').onValue((val)-> console.log('Model.foo is now', val))
m.set(foo: 'baz')
# prints 'Model.foo is now foo' and 'Model.foo is now baz'
```

Every event source also has two functions to ease the work on binding things to other things.

`.takeStream(stream)` returns a new stream that is bound to the lifecycle of the object. The counterpart `.dispose()` will end all streams bound that way. Think of them as equivalents to `model.listenTo(...)` and `model.stopListening()`.

### Baconbone view classes

There's a bit of optional boilerplate view code included as well. `Baconbone.View` has functionality to help keep track of child views, while `Baconbone.ModelView` has boilerplate to help render model data, and `Baconbone.CollectionView` has some simple functionality to automatically render collections.

#### Baconbone.View

Baconbone.View has a few functions of interest, most of which will be useful with collection and model views:

`view.addChild(other)` adds other as childview that is bound to the lifecycle of the view.

`view.removeChild(other)` removes a childview and calls `other.remove()`.

`view.findChild(viewOrModel)` finds a registered child view and returns it. You can pass in either a model or a view. In case of the model, the first child view that has the model as `child.model` will be returned. In case of a view, the view passed as parameter will be returned if it is a childview.

`view.remove()` has been augmented to call `view.dispose()` and to also remove (and unbind) all child views.

#### Baconbone.ModelView

`Baconbone.ModelView` is meant to help with rendering model data and reduce code duplication.

Model events: `ModelView` has an additional property that can be defined, `View::modelEvents = {}`. This is a similar hash that `view.events` and will automatically bind the named model events to the view's functions.

Example:
```coffeescript
class ExampleView extends Baconbone.ModelView

  modelEvents: 
    'change:name': 'renderName' # re-renders name when it changes
    'reset': 'render' # renders the entire view again when model is reset
```

DOM bindings: `ModelView` also has an optional `domBindings` property, that will automatically keep a selector up to date with model data. For example, you can instruct your view to always render model's name to DOM element '#name'.

Example
```coffeescript
  # in class ExampleView ...
  
  domBindings: 
    '#name': 'name' # automatically update @$('#name').text(@model.get('name'))
```

Automatic rendering: Rendering has been streamlined (if you want). By default, `view.render()` will trigger event `before:render`, then call `view.data()` that by default serializes the model with `model.toJSON()`, and last pass the data to `view.renderTemplate(data)`, which should do the rendering and return something that's sensible to pass to `@$el.html`. At minimum it's enough to replace `renderTemplate` with a template rendering function that takes the models data and returns html as string.

Example:
```coffeescript
  # in class ExampleView ...
  
  template: Templates['views/example']
  
  initialize: ->
    @asEventStream('after:render').onValue(@, 'renderAvatar')
    
  renderAvatar: ->
    # something that requires the view's dom to be present already
    # eg. dom manipulation

  renderTemplate: (modelData) ->
    @template.render(modelData)
```

#### Baconbone.CollectionView

`Baconbone.CollectionView` is just a minimum functionality collection rendering view. You can define a ModelView class (`CollectionView::modelView = ExampleModelView`) and every model in the collection will create a new instance of that view class, and will be appended to the collection view. Reset and remove events will also be handled automatically. The `Baconbone.CollectionView` also has a `collectionEvents` property, that works like the `ModelView::modelEvents`.

## Usage

Grab `baconbone.js` from `lib`. It requires Backbone and Bacon.js to be available (and of course also Backbones dependencies like Underscore and jQuery). 

`asEventStream` and `asProperty` are also available separately in `lib/backbone_extensions.js`.

## Contributing / building / playing around

Baconbone is written using coffeescript and uses grunt and bower to build the project. So, first you'll need node.js and then you can run

```
npm install
bower install
grunt [build|test|watch]
```

Source files can be found under `src` and everything is build to `lib`. Tests can be found naturally at `test` and are run with jasmine (2.0).

There's a test-runner you can use in browser at `test/test.html`. You can also run tests using phantomjs by using `grunt test` or `grunt watch`.

If you think this is useful in any way, feel free to contribute with pull requests!

## Author

Otto Vehviläinen [@Mumakil](https://twitter.com/Mumakil)

## License

MIT
