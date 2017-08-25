$(document).ready ->

  console.log 'eager_loading'

  # Exercises in statically loaded <article>
  $('div.exercise').each ->
    load_and_prepare_exercise(this)

  if $('#articles').length
    article_load_delay = 800 # In milliseconds.
    articles_loaded = 0
    article_limit = 25 # A first-order heading might contain endless subheadings...

    current_chapter = $('#sidebar li a.active').attr('href').split('/').pop()
    current_first_segment = current_chapter.split('.')[0]
    
    $.each $('#sidebar li a.next'), (i, link) ->
      # TODO: Figure out what the problem with this is (there's
      # an error message on the console, but not always), sometimes
      # articles load in a different order from what their links
      # are in in the sidebar...
      window.setTimeout (->
      
        url = $(link).attr('href')
        this_chapter = url.split('/').pop()
        this_first_segment = this_chapter.split('.')[0]
        
        console.log("Loading #{url}")

        if articles_loaded < article_limit             &&
           current_first_segment == this_first_segment &&
           $(window).height() > $('#articles').height() # FIXME: leads to a race condition!

          # $.get is asynchronous, so anything inside of the
          # function handed to it is not reachable on the outside!      
          $.get url, (article) ->
            
            # Exercises in dynamically loaded <article>s
            $(article).ready ->
              exercises = $(this).find('div.exercise')
              exercises.each ->
                load_and_prepare_exercise(this)
              # FIXME: Only to make legacy audio links look pretty.
              # Remove when exercises are done completely.
              broken_exercise_links = $(this).find("a.file[href$='mp3'][title='C']")
              broken_exercise_links.each ->
                $(this).html("<i class='fa fa-volume-up'></i>")
                  
            $(article).appendTo('#articles').hide().show() # .fadeIn(2500)
            
            $(link).removeClass('next')
            $(link).addClass('active')
    
    # See above...      
    ), Math.floor(i + 1) * article_load_delay

  setTimeout(nav_links_logic, 1000) # Wait for async ops to finish. FIXME: deal with possible race condition!

load_and_prepare_exercise = (exercise) ->

  locale = location.pathname.split('/')[1]
  id = $(exercise).attr('id').split('_')[1]
  
  $(exercise).load "/#{locale}/exercises/#{id}", ->
    
    $(this).find('p span').each ->
      $(this).draggable
        stop: (event, ui) ->
          $(this).css({top: 0, left: 0})

    $(this).find('input').each ->
      chars = $(this).data('size')
      $(this).css('width', "#{1.5 * chars}ch")
      $(this).droppable
        drop: (event, ui) ->
          $(this).val(ui.draggable.text())

    $(this).find('a.reveal').click ->
      $(this).parent().children('input').each ->
        if $(this).val() == $(this).data('key-value')
          $(this).attr('class', 'correct')
        else if $(this).val() == ''
          $(this).attr('class', 'empty')
          $(this).val($(this).data('key-value'))
        else
          $(this).attr('class', 'incorrect')
      
    $(this).show()
    
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
