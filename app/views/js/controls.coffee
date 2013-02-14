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

  currentSlice: '2 Days'

  getRange: (name) ->
    _.detect @get('timeRanges'), (range) ->
      range.title == name

  initialize: ->
    # Static data for now
    @set('timeRanges', @timeRanges)

  setInitialSlice: ->
    activeSlice = @getRange(@currentSlice)

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

  moveSlice: (direction) ->
    nextSlice = @currentLink[direction]()
    if nextSlice.length
      @moveToSlice(nextSlice)

  left: -> @moveSlice('prev')
  right: -> @moveSlice('next')

  changeSlice: (e) ->
    e.preventDefault()
    @moveToSlice $(e.currentTarget)

  moveToSlice: (link) ->
    @currentLink = link
    rangeTitle = @currentLink.data('title')
    newRange = @model.getRange(rangeTitle)
    return unless newRange

    @model.set
      from: newRange.from
      to: newRange.to
      transform: newRange.transform

    @currentLink.addClass('active')
         .siblings().removeClass('active')

  setInitialSlice: ->
    @currentLink = @$el.find("[data-title='#{@model.currentSlice}']")
        .addClass('active')
    @model.setInitialSlice()
