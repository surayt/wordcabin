$(document).ready ->
  $('main').on('swipeup', ->
    link = $('#next').attr('href')
    if (link != '#')
      window.location.href = link
  )
  $('main').on('swipedown', ->
    link = $('#prev').attr('href')
    if (link != '#')
      window.location.href = link    
  )
