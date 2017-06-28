collapse_toc = ->
  $('nav#sidebar ul.level_2 ul').hide()

make_toc_expandable = ->
  collapse_toc()
  $('nav#sidebar li a').click (e) ->
    collapse_toc()
    Cookies.set('wordcabin_toc_scrollbar_expansion_state', $(this).closest('li.level_2').index())
    $(this).closest('li').find('ul').toggle()
    return
  # Cause links to save the TOC scrollbar position
  # to a cookie so it may be restored upon the page being loaded again.
  $('nav#sidebar a').click (e) ->
    Cookies.set 'wordcabin_toc_scrollbar_position', $('nav#sidebar').scrollTop()
    return

restore_toc_scrollbar_position = ->
  pos = Cookies.get('wordcabin_toc_scrollbar_position')
  $('nav#sidebar').scrollTop pos or 0
  return

restore_toc_expansion_state = ->
  state = Cookies.get('wordcabin_toc_scrollbar_expansion_state')
  if state
    child = parseInt(state) + 1
  else
    child = 1
  $('nav#sidebar li.level_2:nth-child(' + child + ') ul').show() # css('background-color', 'red')
  return
    
add_content_fragment_delete_links = ->
  $('body.editor #sidebar ul li a').each ->
    href = $(this).attr('href')
    $(this).append('&nbsp;<a href="'+href+'" class="btn delete" data-method="delete"><i class="fa fa-trash"></i></a>')

$(document).ready ->
  make_toc_expandable()
  restore_toc_expansion_state()
  restore_toc_scrollbar_position()
  # add_content_fragment_delete_links()
  return
