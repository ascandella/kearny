class Kearny
  constructor: ->
    @setupNavigation()
    @setupViews()

  setupNavigation: ->
    $nav = $('nav')
    navTimer = null

    hideMenu = ->
      navTimer = setTimeout ->
        $nav.addClass('collapsed')
      , 3000

    showMenu = ->
      clearTimeout(navTimer)
      $nav.removeClass('collapsed')

    hideMenu()

    $nav.mouseover showMenu
    $nav.mouseout hideMenu

  setupViews: ->
    @appView = new AppView()

window.KearnyApp = new Kearny()
