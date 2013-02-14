Kearny.AppView = Backbone.View.extend
  el: '#kearny-main'
  gutters: 20
  maxWidth: 400

  initialize: ->
    @dashboard = new Kearny.Dashboard(name: 'default')

    @listenTo(@dashboard, 'add', @addOne)
    @listenTo(@dashboard, 'reset', @addAll)

    $(window).on 'resize', _.debounce(_.bind(@resizeAll, this), 100)
    $('body').on 'keyup', _.bind(@keyUp, this)

    # Set the initial size without rendering
    @resizeAll()
    @dashboard.fetch()
    @subviews = []

    @timeSlice = new Kearny.TimeSlice()
    @timeControl = new Kearny.TimeControl(model: @timeSlice)
    @timeControl.render()

    # Right now these both call the same thing. Maybe eventually we'll be able
    # to handle a fancy effect where we expand horizontally.
    @listenTo(@timeSlice, 'change:from', @updateTimeRange)
    @listenTo(@timeSlice, 'change:to',   @updateTimeRange)

  keyUp: (e) ->
    if e.keyCode == 37
      @timeControl.left()
    else if e.keyCode == 39
      @timeControl.right()

  addOne: (dataSource) ->
    return unless dataSource.valid()

    view        = new Kearny.DataView(model: dataSource)
    view.width  = @subviewWidth
    view.height = @subviewHeight

    @$el.append view.render().el
    @subviews.push view

  addAll: ->
    @$el.empty()
    @dashboard.each(@addOne, this)

    # This also fires off the initial data pull
    @timeControl.setInitialSlice()

  resize: (subview, width, height, render) ->
    subview.width = width
    subview.height = height
    subview.renderGraph() if render

  resizeAll: (render) ->
    viewportWidth   = @$el.width()
    horizontalCount = Math.floor(viewportWidth / @maxWidth)

    @subviewWidth   = Math.floor((viewportWidth / horizontalCount) -
                                 (@gutters * horizontalCount))

    @subviewHeight = Math.floor(@subviewWidth * (2 / 3))
    _.each @subviews, (subview) =>
      @resize(subview, @subviewWidth, @subviewHeight, render)

  windowResized: -> resizeAll(true)
  updateTimeRange: ->
    _.each @subviews, (subview) =>
      subview.model.set
        to:        @timeSlice.get('to')
        from:      @timeSlice.get('from')
        transform: @timeSlice.get('transform')

  advance: ->
    @timeControl.right()
