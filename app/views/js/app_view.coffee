Kearny.AppView = Backbone.View.extend
  el: '#kearny-main'
  gutters: 30
  maxWidth: 400

  initialize: ->
    @dashboard     = new Kearny.Dashboard(name: 'default')
    @configuration = new Kearny.Configuration()

    @listenTo(@dashboard, 'add', @addOne)
    @listenTo(@dashboard, 'reset', @addAll)

    @listenTo(@configuration, 'change:dashboards', @dashboardsChanged)
    @listenTo(@configuration, 'change:timewindows', @timeWindowsChanged)

    $(window).on 'resize', _.debounce(_.bind(@resizeAll, this), 100)
    $('body').on 'keyup', _.bind(@keyUp, this)

    @configuration.fetch()
    # Set the initial size without rendering
    @resizeAll()
    @subviews = []

    @timeSlice   = new Kearny.TimeSlice()
    @timeControl = new Kearny.TimeControl(model: @timeSlice)

    # Right now these both call the same thing. Maybe eventually we'll be able
    # to handle a fancy effect where we expand horizontally.
    @listenTo(@timeSlice, 'change:from change:to', @updateTimeRange)

    @setupAutoAdvance()

  advance: -> @timeControl.right()

  setupAutoAdvance: ->
    @advanceTimer = setInterval _.bind(@advance, this), 30000

  timeWindowsChanged: ->
    @timeSlice.set(timeWindows: @configuration.get('timewindows'))
    @timeControl.render()

  dashboardsChanged: ->
    # TODO: Don't always display the first?
    @dashboard.name = @configuration.get('dashboards')[0]
    @dashboard.fetch()

  keyUp: (e) ->
    clearInterval(@advanceTimer)
    @setupAutoAdvance()

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
    horizontalCount = Math.max(Math.floor(viewportWidth / @maxWidth), 1)
    effectiveWidth  = viewportWidth - (@gutters * horizontalCount)
    @subviewWidth   = Math.floor(effectiveWidth / horizontalCount)
    @subviewHeight  = Math.floor(@subviewWidth * (2 / 3))

    _.each @subviews, (subview) =>
      @resize(subview, @subviewWidth, @subviewHeight, render)

  windowResized: -> resizeAll(true)
  updateTimeRange: ->
    _.each @subviews, (subview) =>
      subview.model.set
        to:        @timeSlice.get('to')
        from:      @timeSlice.get('from')
        transform: @timeSlice.get('transform')
