$(document).ready ->
  $('nav#mobilemenu a.button').click (e) ->
    e.preventDefault()
    $('nav#mobilemenu div.toc').toggle()
  $('nav#mobilemenu div.toc a').click (e) ->
    $('nav#mobilemenu div.toc').hide()
