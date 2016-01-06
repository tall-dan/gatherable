# Gatherable [![Build Status](https://travis-ci.org/schepedw/gatherable.svg)](https://travis-ci.org/schepedw/gatherable)

Gatherable is similar to rails scaffolding, but offers a few different
features. You can use Gatherable to dynamically create active record
models, controllers for those models, and routes for those controllers.

Gatherable was conceived with the purpose of gathering information about
the user experience. The idea is to gather various data points and link them
via a global identifier, so that relations between them can later be
analyzed

## Getting Started

### Include the gem in your Gemfile

`gem 'gatherable'`

### Define  what to gather

In the root of your project, run

`rails generate gatherable initializer`

This will create following `config/initializers/gatherable.rb` file

```
Gatherable.configure do |c|
  c.global_identifier :session_id

 # c.data_point :data_point_name, :data_point_type
  c.data_point :price, :decimal
end
```

Name your `global_identifier` however you want (you have ta have
one, sorry), and whatever data points you want to collect. Each data
point will later become its own table (see [below](#generate-migrations)). Gatherable currently
implements simple tables, adding more complex migration funcionality is
on the todo list.

### Generate migrations
Gatherable will auto-generate the migrations to support the data points
you want to collect. The generated tables will live in a created
`gatherable` schema.

`rails generate gatherable migrations`

(you'll also want to run the migrations, of course)

### Mount the engine
In `config/routes.rb`, mount the gatherable engine. It'll look something
like this:

```
Rails.application.routes.draw do
  #whatever routes your app already has
  mount Gatherable::Engine => "/gatherable"`
end
```

### Gather!

Models, controllers, and routes are dynamically defined when you configure
gatherable, so you're ready to roll!

Right now, only `GET` and `POST` routes are created when gatherable is
configured. They look like this:

```
GET '/gatherable/:global_identifier/model_name/:model_id'
POST '/gatherable/:global_identifier/model_name
```

The `create` method for gatherable data points requires a specific param
format, like so:

```
{ data_point_name: { attr_1: 'foo', attr_2: 'bar' } }
```

#### Credit
This was written partially on [Enova's](http://www.enova.com/) time /
dime
