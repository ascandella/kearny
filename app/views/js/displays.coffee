DataSource = Backbone.Model.extend()
  # initialize: ->
    # @data = 'foo'

DataView = Backbone.View.extend
  template: _.template($('#dataview-template').html())

  render: ->
    @$el.html(@template(@model.toJSON()))
    this


Dashboard = Backbone.Collection.extend
  initialize: (attributes) ->
    # Not using normal `get` call here because @get('name') returns `undefined`
    # on initial `fetch()` call.
    @name = attributes.name
  model: DataSource
  url: -> "/dashboard/#{@name}"

window.AppView = Backbone.View.extend
  el: '#kearny-main'

  initialize: ->
    @dashboard = new Dashboard(name: 'default')

    @listenTo(@dashboard, 'add', @addOne)
    @listenTo(@dashboard, 'reset', @addAll)

    @dashboard.fetch()

  addOne: (dataSource) ->
    view = new DataView(model: dataSource)
    @$el.append(view.render().el)

  addAll: ->
    @$el.empty()
    @dashboard.each(@addOne, this)
