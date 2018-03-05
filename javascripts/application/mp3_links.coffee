$(document).ready ->
  console.log 'mp3_links'
  # Can't use $().click() directly because most of the links will be in
  # dynamically loaded articles which are only accessible via their parent.
  $('#articles').on 'click', 'a[href$="mp3"]', (e) ->
    $('audio').trigger 'pause'
    $('audio').hide()
    url = $(this).attr 'href'
    if $(this).hasClass('with_player')
      player_html = "<audio controls class='visible' src='#{url}' type='audio/mp3'/>"
    else
      player_html = "<audio src='#{url}' type='audio/mp3'/>"
    player = $(this).after player_html
    $(this).next('audio').trigger 'play'
    e.preventDefault()
