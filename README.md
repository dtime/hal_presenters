# HalPresenters

Extracted from dtime.com codebase, still needs a lot of cleaning up.


## Installation

Add this line to your application's Gemfile:

    gem 'hal_presenters'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hal_presenters

## Usage


**Presenter Objects:**
* Presenters respond to #present which takes a presentation\_type argument :full vs :embedded
* Presenters mix in HalPresenters::Helpers::Hypermedia, which in turn mixes in a bunch of helpers. These define some DSL methods that can be used, such as #self.exposes, #self.expose\_embedded, and #self.rel.
* Most of the helpers "expose" an attribute to the world in some way. To see an attribute defined on a model, it has to be "exposed".
* Most of the helpers run as filters called by the #present method, allowing them to be disabled if necessary.


**Presentation Helper**
* Presentation Workflow

1. ThingyPresenter.new(model or hashie::mash)
2. Presenter#present(:full)
  => Presenter#full  (returns hash-like obj)  (called by PresentationHelpers::Present#present)
3. run through default\_filters, each takes in the object and returns a modified version (called by PresentationHelpers::Present)
4. run through presentation specific filters, each takes in the object and returns a modified version (called by PresentationHelpers::Present)
5. run default_after_filters, each takes in the object and returns a modified version (called by PresentationHelpers::Present)
6. Hash-like object ready for JSON rendering (returned by HalPresenters::Helpers::Present#present)

Helpers
-----------------------------

**Present**

* #self.presentation defines a named presentation and set of filters to run when that presentation is called. A lot of the other helper classes are filters that can be optionally included in a presentation.

  `  presentation :full, :linkify, :embedify
  `
  Will define a presentation of :full with #linkify and #embedify filters called on the object before returning it.

  Presentation filters must take in a Hashie::Mash like object, and return a modified version of the object back out.


**Emeddable**

* #self.expose\_embedded which will expose an attribute as an embedded object for hal:

   `   expose_embedded :user, UserPresenter
   `
  will make it so when the item is presented, it has the option of embedding user.

* #embedify will actually include the user in the output object of #present

**Rels**

* #self.rel lets you define a rel to include when calling #linkify. This method takes an opts array that can define :only => [] or :except => [] to exclude it or include it on certain presentations (:only => :full, :except => :special\_case)

  `   rel "dtime:item" do
     "/items/#{model.item_id}"
   end
  `
  Defines a rel that takes the model's item\_id and build a url for it

* #linkify - takes the rels defined and puts them in items, taking into account the :onlys and the :excepts.

  `  {
    _links: {
      "dtime:foo": "/items/bar"
    }
  }
  `
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
