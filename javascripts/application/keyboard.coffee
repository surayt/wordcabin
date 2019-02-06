$(document).ready ->
  $('textarea#paper').focus ->
    if $(this).attr('lang') != 'syr'
      $(this).removeAttr('placeholder')
      $(this).attr('lang', 'syr')
      $(this).val('')
