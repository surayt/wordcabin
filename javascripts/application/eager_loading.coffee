$(document).ready ->

  console.log 'eager_loading'

  article_load_delay = 300 # In milliseconds.
  articles_loaded = 0
  article_limit = 25 # A first-order heading might contain endless subheadings...

  current_chapter = $('#sidebar li a.active').attr('href').split('/').pop()
  current_first_segment = current_chapter.split('.')[0]
  
  $.each $('#sidebar li a.next'), (i, link) ->
    window.setTimeout (->
    
      url = $(link).attr('href')
      this_chapter = url.split('/').pop()
      this_first_segment = this_chapter.split('.')[0]

      if articles_loaded < article_limit && current_first_segment == this_first_segment

        # $.get is asynchronous, so anything inside of the
        # function handed to it is not reachable on the outside!
        $.get url, (article) -> 
          if $(window).height() > $('#articles').height() # FIXME: leads to a race condition!
            $(article).appendTo('#articles').hide().fadeIn(2500)
            $(link).removeClass('next')
            $(link).addClass('active')
          
    ), Math.floor(i + 1) * article_load_delay
