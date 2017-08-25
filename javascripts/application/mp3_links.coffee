$(document).ready ->
  console.log 'mp3_links'
  # Can't use $().click() directly because most of the links will be in
  # dynamically loaded articles which are only accessible via their parent.
  $('#articles').on 'click', 'a[href$="mp3"]', (e) ->
    url = $(this).attr 'href'
    player = $(this).after "<audio src='#{url}' type='audio/mp3'/>"
    $(this).next('audio').trigger 'play'
    e.preventDefault()
