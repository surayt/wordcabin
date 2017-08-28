collapse_toc = ->
  $('#sidebar ul.level_2 ul').hide()

make_toc_expandable = ->
  $('#sidebar li a').click (e) ->
    collapse_toc()
    Cookies.set('wordcabin_toc_scrollbar_expansion_state', $(this).closest('li.level_2').index())
    $(this).closest('li').find('ul').toggle()
  # Cause links to save the TOC scrollbar position
  # to a cookie so it may be restored upon the page being loaded again.
  $('#sidebar li a').click (e) ->
    Cookies.set 'wordcabin_toc_scrollbar_position', $('#sidebar').scrollTop()

restore_toc_state = ->
  # Scrollbar position
  pos = Cookies.get('wordcabin_toc_scrollbar_position')
  $('#sidebar').scrollTop pos or 0
  # Expansion state
  if state = Cookies.get('wordcabin_toc_scrollbar_expansion_state')
    child = parseInt(state) + 1
  else
    child = 1
  $('#sidebar li.level_2:nth-child(' + child + ') ul').show()
    
# TODO: re-enable once we've figured out what
# level of precautions we want to take so people
# can't delete ContentFragments accidentally.
# Ace would be to have an Undo feature...
#add_content_fragment_delete_links = ->
#  $('body.editor #sidebar ul a').each ->
#    href = $(this).attr('href')
#    $(this).append('&nbsp;<a href="'+href+'" class="btn delete" data-method="delete"><i class="fa fa-trash"></i></a>')
# (At the very least, make this work, first...)
#$(document).on 'click', '.delete', (e) ->
#  alert()
#  e.preventDefault()

toggle_sidebar = ->
  $('#logo, #sidebar').toggleClass('hidden')
  $('#content').toggleClass('fullscreen')
  $('#sidebar-handle i').toggleClass('fa-chevron-right')

make_sidebar_hideable = ->
  $('#sidebar-handle').click (e) ->
    toggle_sidebar()
    if $('#sidebar').hasClass('hidden')
      Cookies.set 'wordcabin_toc_sidebar_hidden', 'true'
    else
      Cookies.set 'wordcabin_toc_sidebar_hidden', 'false'

restore_sidebar_state = ->
  hidden = Cookies.get('wordcabin_toc_sidebar_hidden')
  if hidden == 'true'
    toggle_sidebar()
    
add_view_mode_to_chapter_links = ->
  view_mode = url('?view_mode')
  if !!view_mode
    $('#sidebar ul a').each ->
      $(this).attr('href', $(this).attr('href')+'?view_mode='+url('?view_mode'))

$(document).ready ->
  console.log "sidebar"
  if $('#sidebar').length
    make_sidebar_hideable()
    restore_sidebar_state()
    make_toc_expandable()
    restore_toc_state()
    # add_content_fragment_delete_links()
    add_view_mode_to_chapter_links()
