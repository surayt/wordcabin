$(document).ready ->

  $('nav#sidebar a.btn.menu').click (e) ->
    e.preventDefault()
    if $(window).scrollTop() > 0
      $('nav#sidebar section').show()
    else
      $('nav#sidebar a.btn.menu').toggleClass('fixed')
      $('nav#sidebar section').toggle()
    window.scrollTo(0, 0)
    
  $('nav#sidebar section a').click (e) ->
    $('nav#sidebar section').hide()
