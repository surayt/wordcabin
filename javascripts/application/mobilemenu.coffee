$(document).ready ->

  $('#sidebar a.btn.menu').click (e) ->
    e.preventDefault()
    if $(window).scrollTop() > 0
      $('#sidebar section, #session_links').show()
    else
      $('#sidebar a.btn.menu').toggleClass('fixed')
      $('#sidebar section, #session_links').toggle()
    window.scrollTo(0, 0)
    
  $('#sidebar section a').click (e) ->
    $('#sidebar section, #session_links').hide()
