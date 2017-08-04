# Dirty, dirty hack to get rid of those terrible &nbsp; entities 
# TinyMCE throws into everything like a witch throws everything
# into her big pot.
$ ->
  $('td').filter(->
    $(this).text() == '\xa0'
  ).html('')
  
# Make it obvious where the 'lang' attribute has been set.
# $ ->
#   $('#content [lang]').each ->
#     box = "<span class='lang_designator'>"+$(this).attr('lang')+"</div>"
#     $(this).prepend(box)
