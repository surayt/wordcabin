# TODO: Get rid of this as it's basically a copy of
# the same code inside eager_loading.coffee (also see
# comment there...) 
$(document).ready ->
  $('div.exercise').each (index) ->
    locale = location.pathname.split('/')[1]
    id = $(this).attr('id').split('_')[1]
    $(this).load "/#{locale}/exercises/#{id}", ->
      $(this).find('input').each ->
        chars = $(this).data('size')
        $(this).css('width', "#{chars}ch")
      $(this).show()
