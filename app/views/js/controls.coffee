Kearny.TimeSlice = Backbone.Model.extend
  # TODO: Don't hardcode this
  timeRanges: [
    {
      title: '4 Hours', from: '-4hours', to: 'now'
    },
    {
      title: '2 Days',  from: '-2days',  to: 'now',
      transforms: {
        graphite: 'summarize(%s, "30min")'
      }
    },
    {
      title: '2 Weeks', from: '-2weeks', to: 'now',
      transforms: {
        graphite: 'summarize(%s, "1hour")'
      }
    },
  ]

  initialRange: '2 Days'

  getRange: (name) ->
    _.detect @get('timeRanges'), (range) ->
      range.title == name

  initialize: ->
    # Static data for now
    @set('timeRanges', @timeRanges)
    activeSlice = @getRange(@initialRange)

    @set(from: activeSlice.from, to: activeSlice.to)

Kearny.TimeControl = Backbone.View.extend
  el: '#kearny-time-control'

  events:
    'click a': 'changeSlice'

  template: _.template($('#time-control-template').html())

  render: ->
    @$el.html(@template(@model.toJSON()))

  changeSlice: (e) ->
    $link = $(e.currentTarget)
    rangeTitle = $link.data('title')
    newRange = @model.getRange(rangeTitle)
    return unless newRange

    @model.set(from: newRange.from, to: newRange.to, transforms: newRange.transforms)

    $link.addClass('active')
         .siblings().removeClass('active')
