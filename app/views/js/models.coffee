Kearny.DataSource = Backbone.Model.extend
  initialize: ->
    @set('data', {})
  fetchData: -> @fetch type: 'POST', data: configuration: @get('configuration')
  valid: -> !!@get('type')
  url: -> "/data/for/#{@get('type')}"
