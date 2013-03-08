Kearny.Dashboard = Backbone.Collection.extend
  model: Kearny.DataSource
  url: -> "/dashboard/#{@name}.json"
