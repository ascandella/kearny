Kearny.DataSource = Backbone.Model.extend
  fetchData: -> @fetch type: 'POST', data: configuration: @get('configuration')
  valid: -> !!@get('type')
  url: -> "/data/for/#{@get('type')}"

  yDomain: -> @domain(0)
  xDomain: -> @domain(1, 1000)

  domain: (itemIndex, multiplier = 1) ->
    min = d3.min @get('data'), (series) ->
      d3.min series.datapoints, (point) -> point[itemIndex]
    max = d3.max @get('data'), (series) ->
      d3.max series.datapoints, (point) -> point[itemIndex]
    [min * multiplier, max * multiplier]
