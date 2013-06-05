class KearnyApp
  constructor: ->
    @setupAutoUpgrade()
    @setupViews()

  # Periodically poll the server to see if a new application has been deployed.
  # Useful when run in dashboard mode, where the page is left open indefinitely.
  setupAutoUpgrade: ->
    setInterval ->
      Kearny.log "running ping for version newer than #{Kearny.version}"
      $.getJSON '/version', (response) ->
        if Kearny.version != response.version
          Kearny.log "found new version: #{response.version}, reloading..."
          window.location.reload()
    , 60000

  setupViews: ->
    @appView = new Kearny.AppView()

window.Kearny.App = new KearnyApp()
window.Kearny.log = ->
  console.log.apply(console, arguments)
