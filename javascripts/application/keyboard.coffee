$(document).ready ->
  $('#keyboard').keyboard
    layout: 'syriac' # syriac, syriac-phonetic, german-qwertz-1, etc.
    language: null # Set by layout (above line) if null
    rtl: true
    alwaysOpen: true
    initialFocus: true
    noFocus: false
    stayOpen: true
    userClosed: false
    ignoreEsc: true
    closeByClickEvent: false
