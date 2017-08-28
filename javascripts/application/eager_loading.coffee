$(document).ready ->
  console.log 'eager_loading'

  # Exercises in statically loaded <article>.
  # Needed if there are no dynamically loaded <article>s.
  $('div.exercise').each ->
    load_and_prepare_exercise(this)
  
  # Start loading articles if main#articles exists...
  if $('#articles').length
    article_load_delay = 800 # In milliseconds.
    articles_loaded = 0 # Although one has already been loaded statically for graceful fallback.
    article_limit = 5 # A book can consist of indefinitely many articles...

    current_chapter = $('#sidebar li a.active').attr('href').split('/').pop()
    current_first_segment = current_chapter.split('.')[0]
    
    $.each $('#sidebar li a.next'), (i, link) ->
      window.setTimeout (->
        if articles_loaded < article_limit && $(window).height() > $('#articles').height()
          # $.get is asynchronous, so anything inside of the
          # function handed to it is not reachable on the outside!
          url = $(link).attr('href')
          console.log("loading #{url}")
          articles_loaded += 1
          $.get url, (article) ->
            # Exercises in dynamically loaded <article>s
            $(article).ready ->
              # Exercises need themselves to be loaded dynamically
              # into the already dynamically loaded <article>s...
              exercises = $(this).find('div.exercise')
              exercises.each ->
                load_and_prepare_exercise(this)
              # FIXME: Only to make legacy audio links look pretty.
              # Remove when exercises are done completely.
              # Should be in hacks.coffee, but needs to be here because of the eager loading...
              broken_exercise_links = $(this).find("a.file[href$='mp3']:contains('C')")
              broken_exercise_links.each ->
                fix_broken_exercise_link(this)
            # After changes inside of <article> are done, show it.
            $(article).appendTo('#articles').hide().show() # No fade-in because it uses too much GPU
            # Make it clear what articles are being currently displayed
            $(link).removeClass('next')
            $(link).addClass('active')
        else
          # Try to apply nav_links_logic as early as possible,
          # but this code won't be reached for all chapters.
          nav_links_logic()
    ), Math.floor(i + 1) * article_load_delay

  # Ensure that nav_links_logic is applied eventually, even
  # at the end of a book. The long timeout should be fine in
  # that case.
  window.setTimeout (-> nav_links_logic()), 3000
  
  # Hack!
  # Only to make legacy audio links look pretty.
  # Remove when interactive exercises are finished.
  # Should be in hacks.coffee, but needs to be here because of the eager loading...
  $("a.file[href$='mp3']:contains('C')").each ->
    fix_broken_exercise_link(this)
fix_broken_exercise_link = (link) ->
  if $(link).html() == 'C'
    $(link).html("<i class='fa fa-volume-up'></i>")

# TODO: Figure out why it loads exercises inside statically
# loaded <article>s another time when those inside dynamically
# loaded <article>s are loaded?
load_and_prepare_exercise = (exercise) ->
  # Load the exercise into the chapter text...
  locale = location.pathname.split('/')[1]
  id = $(exercise).attr('id').split('_')[1]
  url = "/#{locale}/exercises/#{id}"
  console.log "loading #{url}"
  $(exercise).load url, ->
    # ... and once it is loaded,
    # make draggable things draggable,
    $(this).find('.words span').each ->
      $(this).draggable
        stop: (event, ui) ->
          $(this).css({top: 0, left: 0})
    # ... droppable things droppable,
    $(this).find('.texts input').each ->
      chars = $(this).data('size')
      $(this).css('width', "#{1.5 * chars}ch")
      $(this).droppable
        drop: (event, ui) ->
          $(this).val(ui.draggable.text())
    # ... and make the reveal button
    # reveal things, so it shall have
    # purpose and meaning.
    $(this).find('.legend .reveal').click ->
      $(this).parents('div').find('.texts input').each ->
        if $(this).val() == $(this).data('key-value')
          $(this).attr('class', 'correct')
        else if $(this).val() == ''
          $(this).attr('class', 'empty')
          $(this).val($(this).data('key-value'))
        else
          $(this).attr('class', 'incorrect')
    # When all is done, finally appear!
    $(this).show()

# These are the big "previous" and "next" buttons
# above the first and below the last visible <article>.
nav_links_logic = ->
  if $('#prev').attr('href') == '#' && $('#next').attr('href') == '#'
    console.log 'nav_links_logic'
    # Figure out what the currently active link's index is.
    # Needed for use in jquery's .eq() function...
    i = 0
    $('#toc a').each (a) ->
      if $(this).attr('class') == 'active'
        i = a
        return false
    # Previous chapter.
    # If none, hide the #prev link.
    prev_href = $('#toc a').eq(i-1).attr('href')
    first_link = $('#toc a')[0]
    current_link = $('#toc a').eq(i)[0]
    if prev_href && first_link != current_link
      $('.nav-links#prev').attr('href', prev_href)
    else
      $('.nav-links#prev').hide()
      $('article:first-child').css('padding-top', '2.5em')
    # Number of currently loaded <article>s.
    # Needed to know which one comes after...
    n = $('#toc a.active').length
    # Next chapter.
    # If none, hide the #next link.
    next_href = $('#toc a').eq(i+n).attr('href')
    current_link = $('#toc a').eq(i+n-1)[0]
    last_link = $('#toc a:last-child')
    last_link = last_link[last_link.length-1]
    # Note for debugging: it might have to do with the timing (nav_links_logic might already be called upon _before_
    # the last article has finished loading. TODO: Solve the problem by working with promises instead.
    # console.log "current_link: #{current_link}\nlast_link: #{last_link}\nnext_href: #{next_href}\ni: #{i}\nn: #{n}"
    if next_href && current_link != last_link
      $('.nav-links#next').attr('href', next_href)
    else
      $('.nav-links#next').hide()
