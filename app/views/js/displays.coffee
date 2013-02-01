window.DataSource = Backbone.Model.extend()
  # initialize: ->
    # @data = 'foo'

window.DataView = Backbone.View.extend
  tagName: 'div'
  template: _.template($('#dataview-template').html())

  render: ->
    @$el.html(@template(@model.toJSON()))
    this


window.ViewCollection = Backbone.Collection.extend
  model: DataSource
  url: '/dynamic/views'

window.AppView = Backbone.View.extend
  el: '#kearny-main'

  initialize: ->
    @displays = new ViewCollection

    @listenTo(@displays, 'add', @addOne)
    @listenTo(@displays, 'reset', @addAll)

    @displays.fetch()

  addOne: (dataSource) ->
    view = new DataView(model: dataSource)
    @$el.append(view.render().el)

  addAll: ->
    @$el.empty()
    @displays.each(@addOne, this)
