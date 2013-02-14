Kearny.TimeSlice = Backbone.Model.extend
  # TODO: Don't hardcode this
  timeRanges: [
    {
      title: '4 Hours', from: '-4hours', to: 'now',
      transform: {
        graphite: 'summarize(%s, "5min")'
      }
    },
    {
      title: '2 Days',  from: '-2days',  to: 'now',
      transform: {
        graphite: 'summarize(%s, "30min")'
      }
    },
    {
      title: '1 Week', from: '-1week', to: 'now',
      transform: {
        graphite: 'summarize(%s, "2hour")'
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

  setInitialSlice: ->
    activeSlice = @getRange(@initialRange)

    @set
      from: activeSlice.from
      to: activeSlice.to
      transform: activeSlice.transform

Kearny.TimeControl = Backbone.View.extend
  el: '#kearny-time-control'

  events:
    'click a': 'changeSlice'

  template: _.template($('#time-control-template').html())

  render: -> @$el.html(@template(@model.toJSON()))

  changeSlice: (e) ->
    e.preventDefault()
    $link = $(e.currentTarget)
    rangeTitle = $link.data('title')
    newRange = @model.getRange(rangeTitle)
    return unless newRange

    @model.set
      from: newRange.from
      to: newRange.to
      transform: newRange.transform

    $link.addClass('active')
         .siblings().removeClass('active')

  setInitialSlice: ->
    @$el.find("[data-title='#{@model.initialRange}']")
        .addClass('active')
    @model.setInitialSlice()
