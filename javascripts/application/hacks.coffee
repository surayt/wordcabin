$ ->

  # Dirty, dirty hack to get rid of those terrible &nbsp; entities 
  # TinyMCE throws into everything like a witch throws everything
  # into her big pot.
  # TODO: apply on(load) as well...
  $('tr td').filter(->
    $(this).text() == '\xa0' || $(this).text() == '&nbsp;'
  ).html('')
