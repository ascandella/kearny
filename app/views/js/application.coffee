$nav = $('nav')

autoHide = setTimeout((-> $nav.addClass('collapsed')), 5000)
$nav.mouseover -> clearTimeout(autoHide)
