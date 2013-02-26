Kearny.Dashboard = Backbone.Collection.extend
  initialize: (attributes) ->
    # Not using normal `get` call here because @get('name') returns `undefined`
    # on initial `fetch()` call.
    @name = attributes.name
  model: Kearny.DataSource
  url: -> "/dashboard/#{@name}.json"
