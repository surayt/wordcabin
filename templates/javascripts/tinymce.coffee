config = {}

resize = ->
  setTimeout (->
    # Main container
    max = $('.mce-tinymce').css('border', 'none').parent().outerHeight()
    # Menubar
    max += -$('.mce-menubar.mce-toolbar').outerHeight()
    # Toolbar
    max -= $('.mce-toolbar-grp').outerHeight()
    # Random fix lawl - why 1px? no one knows
    max -= 45
    # Set the new height
    $('.mce-edit-area').height max
    return
  ), 200
  return

config = $.extend(config,
  resize: false
  width: '100%'
  height: '100%'
  autoresize: true
  selector: 'div#content textarea'
  removed_menuitems: 'newdocument'
  plugins: 'table save directionality'
  statusbar: false
  toolbar: 'save | undo redo | bold italic | alignleft aligncenter alignright | bullist numlist outdent indent | ltr rtl')
$(window).on 'resize', ->
  resize()
  return

config.init_instance_callback = (editor) ->
  resize()
  return

tinymce.init config
