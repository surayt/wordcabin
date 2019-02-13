$ ->
  $('#locale_select').change ->
    current_locale = $('#content').attr('lang')
    new_locale = $(this).val()
    new_url = window.location.href.replace("/#{current_locale}/", "/#{new_locale}/")
    window.location.replace(new_url)
