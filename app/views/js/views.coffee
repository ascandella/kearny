Kearny.DataView = Backbone.View.extend
  defaultScale: 'day'
  height: 400
  width: 600
  xPadding: 30
  yPadding: 20

  initialize: ->
    @listenTo(@model, 'change', @render)
    @listenTo(@model, 'destroy', @remove)

  className: 'dataView'

  events:
    'dblclick' : 'open'

  open: -> @$el.addClass 'active'

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
    @yAxisMarker = @svg.append('g')
        .attr('class', 'y axis')
        .attr('transform', "translate(#{@xPadding}, 0)")

    @xAxisMarker = @svg.append('g')
        .attr('class', 'x axis')

  resize: ->
    return unless @svg

    @svg.transition()
        .attr('height', @height)
        .attr('width', @width)

    @xScale.range([@xPadding, @width - @xPadding])
    @yScale.range([@height - @yPadding, @yPadding])

    yAxis = d3.svg.axis().scale(@yScale)
                  .orient('left')

    xAxis = d3.svg.axis().scale(@xScale)

    @xAxisMarker
        .attr('transform', "translate(0, #{@height - @yPadding})")
        .call(xAxis)
    @yAxisMarker.call(yAxis)

    verticalPadding  = @$el.innerHeight() - @$el.height()
    horizontalPadding = @$el.innerWidth()  - @$el.width()

    @$el.width(@width + horizontalPadding)
        .height(@height + verticalPadding)

  renderGraph: ->
    @setupGraph() unless @svg
    @resize()

    z = d3.scale.category20c()

    area = d3.svg.area()
             .interpolate('monotone')
             .x((d) => @xScale(d[1] * 1000))
             .y1((d) => @yScale(d[0]))
             .y0(@height - @yPadding)

    @svg.selectAll('path')
         .data(@model.get('data'), (d) -> d.target)
         .attr('d', (d) -> area(d.datapoints))
         .enter()
           .append('path').transition()
           .attr('d', (d) -> area(d.datapoints))
           .attr('fill', (_, i) -> z(i))


Kearny.AppView = Backbone.View.extend
  el: '#kearny-main'
  gutters: 40
  minWidth: 200
  maxWidth: 400

  initialize: ->
    @dashboard = new Kearny.Dashboard(name: 'default')

    @listenTo(@dashboard, 'add', @addOne)
    @listenTo(@dashboard, 'reset', @addAll)

    $(window).on 'resize', _.debounce(_.bind(@resizeAll, this), 100)

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

  resize: (subview, width, height) ->
    subview.width = width
    subview.height = height
    subview.renderGraph()

  resizeAll: ->
    viewportWidth = @$el.width()
    horizontalCount = Math.floor(viewportWidth / @maxWidth)
    newWidth = (viewportWidth / horizontalCount) - (@gutters * horizontalCount)

    newHeight = newWidth * (2 / 3)
    _.each(@subviews, (subview) => @resize(subview, newWidth, newHeight))
