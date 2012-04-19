---
title: Flowerbox -- a multi-environment, multi-runner, super-easy JavaScript testing framework framework.
layout: default
---
# Flowerbox
## A multi-environment, multi-runner, super-easy JavaScript testing framework framework.
---
## Super-fast unit testing getting started super guide!
### (you need Firefox at the very least)

{% highlight sh %}
gem install flowerbox
flowerbox plant jasmine
flowerbox spec/javascripts
{% endhighlight %}

## ...and what about integration testing?
### (whoa nelly, pure JS Cucumber?)

{% highlight sh %}
flowerbox plant cucumber
flowerbox js-features
{% endhighlight %}

## Hey, I'm already using `jasmine-gem` or `jasmine-headless-webkit`
### (you're smart!)

{% highlight sh %}
flowerbox transplant spec/javascripts
flowerbox spec/javascripts
{% endhighlight %}

## I use Sprockets and need to configure asset paths and templates and stuff!
### (...may the force be with you...)

{% highlight ruby %}
# in spec/javascripts/spec_helper.rb

require 'haml-sprockets'

Flowerbox.configure do |c|
  c.asset_paths << "app/assets/javascripts"
  c.asset_paths << "vendor/assets/javascripts"

  c.additional_files << "applications.js.coffee"

  # ... other stuff ...
end
{% endhighlight %}

## Firefox is so 2008. Can I run my tests on Chrome?
### (we like Selenium here!)

{% highlight ruby %}
Flowerbox.configure do |c|
  c.run_with :chrome
end
{% endhighlight %}

## Chrome is so 2010. Can I run my tests on node.js?
### (evented hipness! jsdom will give you a fake DOM to work with.)

{% highlight ruby %}
# make sure node and npm are in your path
# jsdom and ws get installed in your project under node_modules

Flowerbox.configure do |c|
  c.run_with :node
end
{% endhighlight %}

{% highlight coffeescript %}
# make sure you bind your global things to this

class @MyCoolClass extends @MyBaseClass
  cool: -> "yeah man"
{% endhighlight %}

## Where'd headless support go?!

No, I knew you'd ask. Read the long bit of text below. _tl;dr_: Selenium with Chrome is
pretty much the same setup, just as fast, and gives you stack traces and other debugging assistance.

---

# Plant some Jasmine

---

# Plant a Cucumber or two

## Make a feature like in big boy Cucumber
### (that's 'cause it *is* big boy Cucumber, just in JS form)

{% highlight gherkin %}
# js-features/features/my_cool_thing.feature

Feature: My Cool Thing
  Scenario: Show a cool thing
    Given I have a cool thing
      And I have a cool thing viewer
    When I render the viewer
    Then I should see the cool thing in the viewer

  @wip # <= tags work, too!
  Scenario: Maybe do something else
    Given something
    When yadda
    Then BAM
{% endhighlight %}

## Write some steps
### (Flowerbox gives you a donut-full of syntactic sugar that wraps around Cucumber.js. Be sure to drink lots of water!)

{% highlight coffeescript %}
# js-features/steps/given/i_have_a_cool_thing.js.coffee

Flowerbox.Given /^I have a cool thing$/, ->
  @data =
    one: 'two'
    three: 'four'

  @coolThing = new CoolThing(@data)
{% endhighlight %}

{% highlight coffeescript %}
# js-features/steps/given/i_have_a_cool_thing_viewer.js.coffee

Flowerbox.Given /^I have a cool thing viewer$/, ->
  @coolThingViewer = new CoolThingViewer(@coolThing)
{% endhighlight %}

{% highlight coffeescript %}
# js-features/steps/when/i_render_the_viewer.js.coffee

Flowerbox.When /^I render the viewer$/, ->
  @coolThingViewer.render()
{% endhighlight %}

{% highlight coffeescript %}
# js-features/steps/then/i_should_see_the_cool_thing.js.coffee

Flowerbox.Then /^I should see the cool thing in the viewer$/, ->
  @expect(
    @coolThingViewer.$('input[name="one"]').val()
  ).toEqual(@data.one)

  @expect(
    @coolThingViewer.$('input[name="three"]').val()
  ).toEqual(@data.three)
{% endhighlight %}

## Get some hooks up in here!
### (and other fun environment stuff)

{% highlight coffeescript %}
# js-features/support/env.js.coffee
#
#= require ../steps

Flowerbox.World ->
  @Before (callback) ->
    @something = 'is available everywhere'
    callback()

  @After (callback) ->
    Put = 'some stuff back'
    callback()
{% endhighlight %}

## Auto-generate missing steps
### (see [cucumber-step_writer](http://github.com/johnbintz/cucumber-step_writer) for my philosophy)

{% highlight ruby %}
# js-features/spec_helper.rb

Flowerbox.configure do |c|
  c.report_with :verbose
  c.reporters.add(
    :step_writer,
    :target => 'js-features/step_definitions',
    :on_finish => lambda { |dir| system %{open #{dir}} }
  )
end
{% endhighlight %}
---

# Flowerbox! Yea...wha?

So I (John) have been in this JavaScript testing game for a while, and, after about
three years of doing JS testing for Web apps, decided to finally take all the knowledge I had
and make something that was dead-simple to use.

## You already did once...

`jasmine-headless-webkit` was my first attempt, but it's a C++/Qt mess. Downloading all of
Qt is a total pain. Also, Qt4's JavaScript engine, JavaScriptCore, doesn't have stack trace
support, so it got pretty useless for me for bigger, messy projects (looking at you, Backbone).
Qt5 has V8, but whatever, I just decided to ditch the whole
compiling software thing and replace it with running tests in Selenium and/or node.js.

## Selenium faster than headless? But CI servers--

Sure, spinning up that instance of Firefox or Chrome is slower than starting up a small
QtWebKit widget, but there's a lot less that can go wrong when using a full-blown
browser. This also means your CI server config stays leaner. You may already have Qt installed
for capybara-webkit, but one less thing depending on Qt just makes your life (and mine) easier.

Also, when running Flowerbox with Guard, your browser stays open between test runs, so you only
pay the startup penalty once.

And, if you write everything correctly, you can just run your tests on node.js and not even have
to worry about a browser.

## But you said fake browsers are teh bad--

I changed my mind. As long as I'm not testing for browser-only things, like CSS interaction
or position elements, running tests on node.js with a browser-like DOM provided by jsdom
really is good enough. I use full-blown Ruby Cucumber if I need to test more complex browser
things.

## Cucumber.js? Full-stack testing is the only way!

Yeah, and it's slow. I'll carve out what I can in Cucumber.js while I work on Ruby Cucumber
features. Makes the process of getting those complex integration tests written a lot faster.

Also, I've changed my views on unit testing as a process. Unit testing for me is now about
two things:

* Code design through a liberal use of stubs and mocks.
* Really quickly running through blg blobs of inputs/outputs (parsers and such).

Treating unit testing this way taught me how to better organize and design my code, and I
only use it for really testing code when I need to test those big blobs of things.
This is my opinion, YMMV, Flowerbox lets you do what you want. Never use Cucumber.js support
if you don't want to. Write your integration bits in Jasmine. I don't mind.

