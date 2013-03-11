Kearny.DataView = Backbone.View.extend
  defaultFormat: 'area'
  height: 400
  width: 600
  xPadding: 40
  yPadding: 20
  yAxisVisible: false

  initialize: ->
    @listenTo(@model, 'change:data change:error change:format', @dataUpdated)
    @listenTo(@model, 'refresh', @fetchData)

    @listenTo(@model, 'destroy', @remove)

  className: 'dataView'

  events:
    'click svg': 'cycleFormat'

  fetchData: ->
    @model.fetchData()
    @$el.addClass('loading')
        .removeClass('has-content has-data')

  getFormat: -> @model.get('format') || @defaultFormat

  cycleFormat: ->
    formats = _.keys(@generators)
    nextFormat = @getFormat()

    while (nextFormat == @getFormat())
      nextFormat = formats[Math.floor(Math.random() * formats.length)]

    @model.set('format', nextFormat)

  template: _.template($('#dataview-template').html())

  dataUpdated: ->
    @$el.removeClass('loading')

    if @model.get('error')
      @$el.addClass('error')
          .find('.error-message')
            .text(@model.get('message'))

    else if @model.get('data')
      @$el.removeClass('error')
          .addClass('has-data')
      @renderGraph()

    else if @model.get('text')
      @$el.removeClass('error')
          .addClass('has-text')
          .find('.text-content').html(@model.get('text'))

  render: ->
    @$el.html(@template(@model.toJSON()))
    this

  updateDomain: ->
    @xScale = d3.time.scale().domain @model.xDomain()
    @yScale = d3.scale
                .linear()
                .domain(@model.yDomain())

  setupGraph: ->
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
    @$el.find('svg')
        .width(@width)
        .height(@height)

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

  stylers:
    line: (el) ->
      z = d3.scale.category20()
      el.attr('fill', 'none')
        .attr('stroke', (_, i) -> z(i))
        .attr('stroke-width', 2)
    area: (el) ->
       z = d3.scale.category20()
       el.attr('fill', (_, i) -> z(i))
         .attr('stroke', 'none')

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
    return if @model.has('error')
    @$el.removeClass('has-content')

    @setupGraph() unless @svg
    @updateDomain()
    @resize()
    lineFunction = _.bind(@generators[@getFormat()], this)()

    data = @model.get('data')

    el = @svg.selectAll('path')
             .data(data, (d) -> d.target)
             .attr('d', (d) -> lineFunction(d.datapoints))

    # Add new entries
    el.enter()
      .append('path').transition()
      .attr('d', (d) -> lineFunction(d.datapoints))

    # Remove old entries
    el.exit().remove()

    # Make areas overlap if necessary
    opacity = if @model.get('data').length > 1 then 0.85 else 1
    el.style('opacity', opacity)

    @stylers[@getFormat()](el)

    @$el.addClass('has-content')
