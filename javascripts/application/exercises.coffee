$(document).ready ->  
  console.log 'exercises'
  exercises = $('div.exercise')
  $('div.exercise').each (index) ->
    locale = location.pathname.split('/')[1]
    id = $(this).attr('id').split('_')[1]
    $(this).load("/#{locale}/exercises/#{id}")
  exercises.show()
