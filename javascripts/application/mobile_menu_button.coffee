$(document).ready ->
  console.log "mobile_menu_button"
  $('#mobile-menu-button').click (e) ->
    e.preventDefault()
    if $(window).scrollTop() > 0
      $('#sidebar section, #session-links').show()
    else
      $('#mobile-menu-button').toggleClass('fixed')
      $('#sidebar section, #session-links').toggle()
    window.scrollTo(0, 0)    
  $('#sidebar section a').click (e) ->
    $('#sidebar section, #session-links').hide()
