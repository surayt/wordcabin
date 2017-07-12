# Dirty, dirty hack to get rid of those terrible &nbsp; entities TinyMCE throws into everything like a witch throws everything into her big pot.
$ ->
  $('td').filter(->
    $(this).text() == '\xa0'
  ).html('')
