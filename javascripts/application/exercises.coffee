$(document).ready ->
  $('div.exercise').each (index) ->
    locale = location.pathname.split('/')[1]
    id = $(this).attr('id').split('_')[1]
    $(this).load("/#{locale}/exercises/#{id}")
    $(this).show()
    console.log $(this)
    console.log "Hello, I'm the good guy. I work just fine."
