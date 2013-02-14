Kearny.DataSource = Backbone.Model.extend
  initialize: ->
    @on('change:transform', @updateTransform)
    @on('change:targets', @recordTargets)
    @recordTargets()

  fetchData: ->
    @fetch
      contentType: 'application/json'
      data: JSON.stringify(this)
      type: 'POST'

  toJSON: ->
    attributes = _.extend({}, @attributes)
    delete attributes.data
    attributes

  valid: -> @has('type')
  url: '/data/for'

  yDomain: -> [0, @domain(0)[1]]
  xDomain: -> @domain(1, 1000)

  domain: (itemIndex, multiplier = 1) ->
    min = d3.min @get('data'), (series) ->
      d3.min series.datapoints, (point) -> point[itemIndex]
    max = d3.max @get('data'), (series) ->
      d3.max series.datapoints, (point) -> point[itemIndex]
    [min * multiplier, max * multiplier]

  updateTransform: ->
    transforms = @get('transform')

    if transforms
      transform = transforms[@get('type')]

      if transform
        # Don't use setter, avoid loop
        @attributes.targets = _.map @get('originalTargets'), (target) ->
          transform.replace('%s', target)

    else
      @attributes.targets = @get('originalTargets')

    @trigger('refresh')

  recordTargets: -> @set('originalTargets', @get('targets'))
