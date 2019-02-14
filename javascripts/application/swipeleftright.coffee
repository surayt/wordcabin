$ ->
  if /Mobi/i.test(navigator.userAgent) or /Android/i.test(navigator.userAgent)

    console.log "swipeleftright"

    $('main').on('swipeleft', ->
      $('#swipeleft').fadeIn().fadeOut()
      console.log "user swiped left"
      link = $('#next').attr('href')
      if (link != '#')
        window.location.href = link
    )

    $('main').on('swiperight', ->
      $('#swiperight').fadeIn().fadeOut()
      console.log "user swiped right"
      link = $('#prev').attr('href')
      if (link != '#')
        window.location.href = link
    )
