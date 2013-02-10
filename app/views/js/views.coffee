Kearny.DataView = Backbone.View.extend
  initialize: ->
    @listenTo(@model, 'change', @render)
    @listenTo(@model, 'destroy', @remove)

  template: _.template($('#dataview-template').html())

  render: ->
    @$el.html(@template(@model.toJSON()))
    @$el.data('raw-data', @model.get('data'))
    this

Kearny.AppView = Backbone.View.extend
  el: '#kearny-main'

  initialize: ->
    @dashboard = new Kearny.Dashboard(name: 'default')

    @listenTo(@dashboard, 'add', @addOne)
    @listenTo(@dashboard, 'reset', @addAll)

    @dashboard.fetch()

  addOne: (dataSource) ->
    dataSource.fetchData() if dataSource.valid()
    view = new Kearny.DataView(model: dataSource)
    @$el.append(view.render().el)

  addAll: ->
    @$el.empty()
    @dashboard.each(@addOne, this)
