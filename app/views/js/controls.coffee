Kearny.TimeSlice = Backbone.Model.extend
  initialize: ->
    @on('change:index', @indexChanged)

  defaultIndex: ->
    preferred = 0
    # Wish I could use `_.find` here, but it doesn't return  the index
    _.each @get('timeWindows'), (range, index) =>
      preferred = index if range.default
    preferred

  indexChanged: ->
    newRange = @get('timeWindows')[@get('index')]
    @unset('transform', silent: true)
    @set visibleRange: newRange.title
    @set newRange

  setInitialSlice: -> @set index: @defaultIndex()

  rotate: (direction) ->
    newIndex = @get('index') + direction
    if newIndex >= @get('timeWindows').length
      newIndex = 0
    else if newIndex < 0
      newIndex = @get('timeWindows').length - 1

    @set index: Math.max(0, newIndex)

Kearny.TimeControl = Backbone.View.extend
  el: '#kearny-time-control'

  initialize: ->
    @listenTo(@model, 'change:visibleRange', @render)

  events:
    'click .left' : 'left'
    'click .right': 'right'

  template: _.template($('#time-control-template').html())

  render: ->
    @$el.html(@template(@model.toJSON())) if @model.has('visibleRange')

  left:  -> @model.rotate(-1)
  right: -> @model.rotate(1)

  setInitialSlice: -> @model.setInitialSlice()
