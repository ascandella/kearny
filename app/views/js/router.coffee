Kearny.Router = Backbone.Router.extend
  routes:
    'dashboard/:name': 'dashboard'
    '*actions': 'dashboard'
