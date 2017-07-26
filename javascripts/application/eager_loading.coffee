$(document).ready ->
  console.log "eager_loading"
  body_height = $(document).height()
  articles_loaded = 0
  limit = 10
  $('#sidebar li a.next').each ->
    container_height = $('main.articles').height()
    if body_height > container_height
      url = $(this).attr 'href'
      $(this).removeClass 'next'
      $.get url, (data)-> $(data).find('article').appendTo 'main.articles'
      articles_loaded += 1
      return if articles_loaded > limit
