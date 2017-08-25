$(document).ready ->

  console.log 'eager_loading'

  if $('#articles').length
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

      if articles_loaded < article_limit             &&
         current_first_segment == this_first_segment &&
         $(window).height() > $('#articles').height() # FIXME: leads to a race condition!

        # $.get is asynchronous, so anything inside of the
        # function handed to it is not reachable on the outside!      
        $.get url, (article) -> 
          
          # TODO: There is, basically, a copy of this code in exercises.coffee,
          # even though this part here affects exercises in the statically loaded
          # first article as well already. Somehow there needs to be a way to DRY
          # that situation up.
          $(article).ready ->
            exercises = $(this).find('div.exercise')
            exercises.each (index) ->
              locale = location.pathname.split('/')[1]
              id = $(this).attr('id').split('_')[1]
              $(this).load "/#{locale}/exercises/#{id}", ->
                $(this).show()
                
          $(article).appendTo('#articles').hide().fadeIn(2500)
          
          $(link).removeClass('next')
          $(link).addClass('active')
          
    ), Math.floor(i + 1) * article_load_delay

  setTimeout(nav_links_logic, 1000) # Wait for async ops to finish. FIXME: deal with possible race condition!
    
nav_links_logic = ->

    i = 0
    $('#toc a').each (a) ->
      if $(this).attr('class') == 'active'
        i = a
        return false
      
    if href = $('#toc a').eq(i-1).attr('href')
      $('article:first-child').css('margin-top', '35pt')
      $('#prev').attr('href', href)
      $('#prev').show()
      
    n = $('#toc a.active').length
    
    if href = $('#toc a').eq(i+n).attr('href')
      $('#next').attr('href', href)
      $('#next').show()
