Kearny.DataSource = Backbone.Model.extend
  fetchData: -> @fetch type: 'POST', data: configuration: @get('configuration')
  valid: -> !!@get('type')
  url: -> "/data/for/#{@get('type')}"
