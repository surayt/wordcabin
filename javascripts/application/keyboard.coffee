$(document).ready ->
  $('#keyboard').keyboard
    layout: 'syriac' # 'german-qwertz-1'
    language: null # Set by layout (above line) if null
    rtl: true
    alwaysOpen: true
    initialFocus: true
    noFocus: false
    stayOpen: true
    userClosed: false
    ignoreEsc: true
    closeByClickEvent: false
