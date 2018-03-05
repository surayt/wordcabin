$(document).ready ->
  if /Mobi/i.test(navigator.userAgent) or /Android/i.test(navigator.userAgent)
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
