$ ->
  console.log 'surayt_reshaping'
  
  addZWJ = (html_string) ->
    html_string.replace /((?![ܐܖܕܪܗܘܙܨܬ])[܀-ݏ])(<\/?span(|( |[a-z]|\"|\=)*)\>)/g, '$1&zwj;$2&zwj;'

  $('.exercise_wrapper table:last-child td[lang=syr]').each ->
    $(this).html addZWJ($(this).html())
    console.log "  "+$(this).html()
