DataSource = Backbone.Model.extend
  initialize: ->
    @set('data', {})
  fetchData: -> @fetch type: 'POST', data: configuration: @get('configuration')
  valid: -> !!@get('type')
  url: -> "/data/for/#{@get('type')}"

DataView = Backbone.View.extend
  initialize: ->
    @listenTo(@model, 'change', @render)
    @listenTo(@model, 'destroy', @remove)

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
    dataSource.fetchData() if dataSource.valid()
    view = new DataView(model: dataSource)
    @$el.append(view.render().el)

  addAll: ->
    @$el.empty()
    @dashboard.each(@addOne, this)
