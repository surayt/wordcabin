$(document).ready ->
  $('#locale_select').change ->
    current_locale = $('body').data('content-locale')
    new_locale = $(this).val()
    new_url = window.location.href.replace("/#{current_locale}/", "/#{new_locale}/")
    window.location.replace(new_url)
