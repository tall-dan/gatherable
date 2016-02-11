# Gatherable [![Build Status](https://travis-ci.org/schepedw/gatherable.svg)](https://travis-ci.org/schepedw/gatherable) [![Code Climate](https://codeclimate.com/github/schepedw/gatherable/badges/gpa.svg)](https://codeclimate.com/github/schepedw/gatherable) [![coverage ](https://codeclimate.com/github/schepedw/gatherable/badges/coverage.svg)](https://codeclimate.com/github/schepedw/gatherable)


Use Gatherable to dynamically create active record
models, controllers for those models, and routes for those controllers.
You can even use Gatherable to create Javascript objects to talk to your
new routes.

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
  c.global_identifier = :gatherable_id

  # c.data_point :data_point_name, :data_point_type, OPTIONS - see below
  c.data_point :price, :decimal # new_record_strategy: [:update, :insert] # defaults to :insert

  # c.data_table :table_name, { column_name: :column_type, column_name2: :column_type}, OPTIONS - see below
  c.data_table :requested_loan_amount, { requested_loan_amount: :decimal, total_cost: :decimal, monthly_repayment_amount: :decimal }

  #  for both data tables and data points, you'll automatically get a primary key 'table_name_id',
  #  an indexed global identifier, and timestamps

  # If want your db schema to be something besides 'gatherable', uncomment the line below
  # c.schema_name = 'foo_bar'
end
```

Name your `global_identifier` however you want (you have ta have
one, sorry), and whatever data points you want to collect. Each data
point will later become its own table (see [below](#generate-migrations)).
Should you want more complex tables, use the data_table syntax shown above.

#### Options
Both `data_point`s and `data_table`s take an optional options hash.
Valid keys and values are outlined below.

* `:new_record_strategy`
  * `:insert` - when a new record is `POST`ed, insert it into the db
  * `:update` - instead of immediately inserting, see if there already
    exists a record with the same global id. Yes? update it. No? insert
  * defaults to `:insert`
  * see [below](#saving-some-space) for more information
* `:allowed_controller_actions` - an array containing any of the following:
  * `index`
  * `show`
  * `create`
  * `update`
  * `destroy`
  * defaults to `[:show, :create]`. _this may change in v2_

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

For each data point you're collecting, there are up to five controller
methods already defined for you (you get to choose, see [above](#options)).

For a data point called `price`, the routes for these methods would look
like this:

```
GET    /:session_id/prices(.:format)               =>  #index
POST   /:session_id/prices(.:format)               =>  #create
GET    /:session_id/prices/:price_id(.:format)     =>  #show
PUT    /:session_id/prices/:price_id(.:format)     =>  #update
DELETE /:session_id/prices/:price_id(.:format)     =>  #destroy
```

The `create` and `update` methods for gatherable data points requires a
specific param format, like so:

```
{ data_point_name: { attr_1: 'foo', attr_2: 'bar' } }
```

### Seeing the magic

If you want to customize the models or controllers that Gatherable
dynamically defines, simply generate them:

```
rails generate gatherable models
rails generate gatherable controllers
```

You can also generate simple javascript objects to talk to your
controllers:

```
rails generate gatherable javascripts
```

### Saving some space
If you're using this to track user interactions, you may find that this
engine creates quite a bit of data. In order to alleviate that, you can
use `new_record_strategy` for your data points / tables

`data_point :price, :decimal, new_record_strategy: :update #default is
:insert`

When using the `update` strategy, models will try to find a record with
the same `global_identifier` and update it. A record will be inserted if
there are none with a matching `gatherable_id`

Conversely, the `insert` strategy will not add an `updated_at` column to
your migrations, since you'll be inserting a new record each time

### Security

You may have thought, "This gem pretty much just opens a door to insert
straight to my database!" You would be correct. I'm not sure of
"The Best Way" to fix this. I've got a small bandaid. In
`config/gatherable`, set `config.auth_method = :session`.

Now, when posting a new object, Gatherable will check to see if the
passed `global_identifier` is the same as what is stored in the session.
**Note: it's up to you to put the correctly named variable in your
session**

#### Credit
This was written partially on [Enova's](http://www.enova.com/) time /
dime
