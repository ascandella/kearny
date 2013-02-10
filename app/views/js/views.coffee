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
    if @model.get('data')?.error
      @$el.addClass('error')
          .find('.error-message').text(@model.get('data').message)

    else if @model.get('data')
      @$el.addClass('has-data')
      @renderGraph()

    else if @model.get('text')
      @$el.addClass('has-text')
          .find('.text-content').html(@model.get('text'))

    this

  setupGraph: ->
    @xScale = d3.time.scale()
                     .range([@xPadding, @width - @xPadding])
                     # .nice(d3.time[@model.get('scale') || @defaultScale])

    @yScale = d3.scale.linear()
                      .range([@height - @yPadding, @yPadding])

    @yScale.domain @model.yDomain()
    @xScale.domain @model.xDomain()

    @svg ?= d3.select(@$el[0]).append('svg')

    yAxis = d3.svg.axis().scale(@yScale)
                  .orient('left')

    xAxis = d3.svg.axis().scale(@xScale)

    @svg.append('g')
        .attr('class', 'y axis')
        .attr('transform', "translate(#{@xPadding}, 0)")
        .call(yAxis)

    @svg.append('g')
        .attr('class', 'x axis')
        .attr('transform', "translate(0, #{@height - @yPadding})")
        .call(xAxis)

  resize: ->
    @svg.attr('height', @height)
        .attr('width', @width)

  renderGraph: ->
    @setupGraph() unless @svg
    @resize()

    z = d3.scale.category20c()

    _.each @model.get('data'), (series, i) =>
      area = d3.svg.area()
               .interpolate('monotone')
               .x( (d) => @xScale(d[1] * 1000) )
               .y1( (d) => @yScale(d[0]) )
               .y0(@height - @yPadding)

      @svg.append('path')
          .attr('d', area(series.datapoints))
          .attr('fill', z(i))


Kearny.AppView = Backbone.View.extend
  el: '#kearny-main'

  initialize: ->
    @dashboard = new Kearny.Dashboard(name: 'default')

    @listenTo(@dashboard, 'add', @addOne)
    @listenTo(@dashboard, 'reset', @addAll)

    @dashboard.fetch()

  addOne: (dataSource) ->
    dataSource.fetchData() if dataSource.valid()
    view = new Kearny.DataView(model: dataSource)
    @$el.append(view.render().el)

  addAll: ->
    @$el.empty()
    @dashboard.each(@addOne, this)
