Kearny.TimeSlice = Backbone.Model.extend
  # TODO: Don't hardcode this
  timeRanges: [
    { title: '4 Hours', from: '-4hours', to: 'now' },
    { title: '2 Days',  from: '-2days',  to: 'now' },
    { title: '2 Weeks', from: '-2weeks', to: 'now' },
  ]

  initialRange: '2 Days'

  # Static data for now
  initialize: ->
    @set('timeRanges', @timeRanges)
    activeSlice = _.detect @timeRanges, (range) =>
      range.title == @initialRange

    @set(from: activeSlice.from, to: activeSlice.to)

Kearny.TimeControl = Backbone.View.extend
  el: '#kearny-time-control'

  template: _.template($('#time-control-template').html())

  render: ->
    @$el.html(@template(@model.toJSON()))
