Kearny.TimeSlice = Backbone.Model.extend
  currentSlice: '1 Week'

  getRange: (name) ->
    _.detect @get('timeWindows'), (range) ->
      range.title == name

  setInitialSlice: ->
    activeSlice = @getRange(@currentSlice)

    @set(activeSlice)

Kearny.TimeControl = Backbone.View.extend
  el: '#kearny-time-control'

  events:
    'click a': 'changeSlice'

  template: _.template($('#time-control-template').html())

  render: -> @$el.html(@template(@model.toJSON()))

  moveSlice: (direction) ->
    nextSlice = @currentLink[direction]()
    opposite  = if direction == 'prev' then 'next' else 'prev'
    shuffler  = @currentLink[opposite + 'All']().last()

    surgicalOperation = if direction == 'next' then 'appendTo' else 'prependTo'
    shuffler[surgicalOperation](@currentLink.parent())

    if nextSlice.length
      @moveToSlice(nextSlice)

  left:  -> @moveSlice('prev')
  right: -> @moveSlice('next')

  changeSlice: (e) ->
    e.preventDefault()
    @moveToSlice $(e.currentTarget)

  moveToSlice: (link) ->
    @currentLink = link
    rangeTitle = @currentLink.data('title')
    newRange = @model.getRange(rangeTitle)
    return unless newRange

    @model.set(newRange)

    @currentLink
      .addClass('active')
      .siblings()
        .removeClass('active')

  setInitialSlice: ->
    @currentLink = @$el.find("[data-title='#{@model.currentSlice}']")
      .addClass('active')

    @model.setInitialSlice()
