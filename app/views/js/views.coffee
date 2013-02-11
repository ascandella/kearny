Kearny.DataView = Backbone.View.extend
  defaultScale: 'day'
  defaultFormat: 'area'
  height: 400
  width: 600
  xPadding: 40
  yPadding: 20
  yAxisVisible: false

  initialize: ->
    @listenTo(@model, 'change:data', @render)
    @listenTo(@model, 'change:format', @renderGraph)
    @listenTo(@model, 'destroy', @remove)

  className: 'dataView'

  events:
    'dblclick' : 'fetchData'
    'click'    : 'cycleFormat'

  fetchData: -> @model.fetchData()

  getFormat: -> @model.get('format') || @defaultFormat
  cycleFormat: ->
    formats = _.keys(@generators)
    nextFormat = @getFormat()

    while (nextFormat == @getFormat())
      nextFormat = formats[Math.floor(Math.random() * formats.length)]

    @model.set('format', nextFormat)


  template: _.template($('#dataview-template').html())

  render: ->
    @$el.html(@template(@model.toJSON()))
    if @model.get('error')
      @$el.addClass('error')
          .find('.error-message').text(@model.get('message'))

    else if @model.get('data')
      @$el.addClass('has-data')
      @renderGraph()

    else if @model.get('text')
      @$el.addClass('has-text')
          .find('.text-content').html(@model.get('text'))

    this

  setupGraph: ->
    @xScale = d3.time.scale().domain @model.xDomain()
    @yScale = d3.scale.linear().domain @model.yDomain()

    @svg ?= d3.select(@$el[0]).append('svg')
    if @yAxisVisible
      @yAxisMarker = @svg.append('g')
          .attr('class', 'y axis')
          .attr('transform', "translate(#{@xPadding}, 0)")
    else
      @xPadding = 0

    @xAxisMarker = @svg.append('g')
        .attr('class', 'x axis')

  resize: ->
    return unless @svg

    @svg.transition()
        .attr('height', @height)
        .attr('width', @width)

    # Simply setting the height/width attributes on the SVG element aren't
    # enough for the enclosing div to know its size.
    @$el.find('svg').width(@width).height(@height)

    @xScale.range([@xPadding, @width - @xPadding])
    @yScale.range([@height - @yPadding, @yPadding])

    xAxis = d3.svg.axis().scale(@xScale)
                  .ticks(3)

    @xAxisMarker
        .attr('transform', "translate(0, #{@height - @yPadding})")
        .call(xAxis)

    if @yAxisVisible
      yAxis = d3.svg.axis().scale(@yScale)
                    .orient('left')
                    .ticks(4)
      @yAxisMarker.call(yAxis)

    verticalPadding  = @$el.innerHeight() - @$el.height()
    horizontalPadding = @$el.innerWidth()  - @$el.width()

  stylers:
    area: (el) ->
       z = d3.scale.category20c()
       el.attr('fill', (_, i) -> z(Kearny.colorCounter))
         .attr('stroke', 'none')
    line: (el) ->
      z = d3.scale.category20c()
      el.attr('fill', 'none')
        .attr('stroke', (_, i) -> z(Kearny.colorCounter))
        .attr('stroke-width', 2)

  generators:
    area: ->
      d3.svg.area()
            .interpolate('basis')
            .x((d) => @xScale(d[1] * 1000))
            .y1((d) => @yScale(d[0]))
            .y0(@height - @yPadding)

    line: ->
      d3.svg.line()
            .interpolate('basis')
            .x((d) => @xScale(d[1] * 1000))
            .y((d) => @yScale(d[0]))

  renderGraph: ->
    @setupGraph() unless @svg
    @resize()
    lineFunction = _.bind(@generators[@getFormat()], this)()

    Kearny.colorCounter ?= 0
    Kearny.colorCounter += 1
    data = @model.get('data')

    el = @svg.selectAll('path')
             .data(data, (d) -> d.target)
             .attr('d', (d) -> lineFunction(d.datapoints))
    el.enter()
      .append('path').transition()
      .attr('d', (d) -> lineFunction(d.datapoints))

    @stylers[@getFormat()](el)

    @$el.addClass('has-content')

Kearny.AppView = Backbone.View.extend
  el: '#kearny-main'
  gutters: 20
  maxWidth: 400

  initialize: ->
    @dashboard = new Kearny.Dashboard(name: 'default')

    @listenTo(@dashboard, 'add', @addOne)
    @listenTo(@dashboard, 'reset', @addAll)

    $(window).on 'resize', _.debounce(_.bind(@resizeAll, this), 100)

    # Set the initial size without rendering
    @resizeAll()
    @dashboard.fetch()
    @subviews = []

  addOne: (dataSource) ->
    return unless dataSource.valid()

    dataSource.fetchData()
    view = new Kearny.DataView(model: dataSource)
    @$el.append(view.render().el)
    @subviews.push view

  addAll: ->
    @$el.empty()
    @dashboard.each(@addOne, this)

  resize: (subview, width, height, render) ->
    subview.width = width
    subview.height = height
    subview.renderGraph() if render

  resizeAll: (render) ->
    viewportWidth = @$el.width()
    horizontalCount = Math.floor(viewportWidth / @maxWidth)
    newWidth = Math.floor((viewportWidth / horizontalCount) -
                          (@gutters * horizontalCount))

    newHeight = Math.floor(newWidth * (2 / 3))
    _.each @subviews, (subview) =>
      @resize(subview, newWidth, newHeight, render)

  windowResized: -> resizeAll(true)
