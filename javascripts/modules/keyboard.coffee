$(document).ready ->
      
  $('#paper').keyboard
    layout: 'syriac' # syriac, syriac-phonetic, german-qwertz-1, etc.
    language: null # Set by layout (above line) if null
    rtl: true
    alwaysOpen: true
    initialFocus: false
    noFocus: false
    stayOpen: true
    userClosed: false
    ignoreEsc: true
    closeByClickEvent: false

  $('textarea').click ->
    if $(this).attr('lang') != 'syr'
      $(this).removeAttr('placeholder')
      $(this).attr('lang', 'syr')
      $(this).val('')
