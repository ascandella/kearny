Kearny.DataView = Backbone.View.extend
  initialize: ->
    @listenTo(@model, 'change', @render)
    @listenTo(@model, 'destroy', @remove)

  className: 'dataView'

  events:
    'dblclick' : 'open'

  open: -> @$el.addClass 'active'

  template: _.template($('#dataview-template').html())

  render: ->
    @$el.html(@template(@model.toJSON()))
    if @model.get('data')?.error
      @$el.addClass('error')
          .find('.error-message').text(@model.get('data').message)
    else if @model.get('data')
      @$el.addClass('has-data')
          .data('raw-data', @model.get('data'))
    else if @model.get('text')
      @$el.addClass('has-text')
          .find('.text-content').html(@model.get('text'))
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
