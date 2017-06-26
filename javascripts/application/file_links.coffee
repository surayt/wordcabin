# Add an <audio> tag to all hyperlinks pointing
# towards an mp3 file. So far, nothing else.

$(document).ready ->
  mp3_file_links = 'a.file[href$="mp3"]'
  $(mp3_file_links).each ->
    url = $(this).attr('href')
    player = $(this).after('<audio src="'+url+'" type="audio/mp3"/>')
  $(mp3_file_links).click (e) ->
    e.preventDefault()
    $(this).next('audio').trigger('play')
