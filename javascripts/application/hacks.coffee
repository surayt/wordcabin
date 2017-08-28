$(document).ready ->

  # Dirty, dirty hack to get rid of those terrible &nbsp; entities 
  # TinyMCE throws into everything like a witch throws everything
  # into her big pot.
  # TODO: apply on(load) as well...
  $('tr td').filter(->
    $(this).text() == '\xa0' || $(this).text() == '&nbsp;'
  ).html('')

  # Only to make legacy audio links look pretty.
  # Remove when exercises are done completely.
  # Should be in hacks.coffee, but needs to be here because of the eager loading...
  $("a.file[href$='mp3']:contains('C')").each ->
    fix_broken_exercise_link(this)
