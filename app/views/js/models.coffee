Kearny.DataSource = Backbone.Model.extend
  fetchData: ->
    @fetch
      type: 'POST'
      contentType: 'application/json'
      data: JSON.stringify(this)

  # Don't post back our `data`
  toJSON: ->
    attributes = _.extend({}, @attributes)
    delete attributes.data
    attributes

  valid: -> !!@get('type')
  url: -> '/data/for'

  yDomain: -> @domain(0)
  xDomain: -> @domain(1, 1000)

  domain: (itemIndex, multiplier = 1) ->
    min = d3.min @get('data'), (series) ->
      d3.min series.datapoints, (point) -> point[itemIndex]
    max = d3.max @get('data'), (series) ->
      d3.max series.datapoints, (point) -> point[itemIndex]
    [min * multiplier, max * multiplier]
