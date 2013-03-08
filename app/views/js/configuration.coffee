Kearny.Configuration = Backbone.Model.extend
  name: -> @get('name') || 'default'
  url:  -> "/config/#{@name()}.json"
