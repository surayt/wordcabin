# https://gist.github.com/sheldonh/6089299
merge = (xs...) ->
  if xs?.length > 0
    tap {}, (m) -> m[k] = v for k, v of x for x in xs
tap = (o, fn) -> fn(o); o

common_settings =
  statusbar: false
  menubar: false
  branding: false
  invalid_styles: 'width height'
  style_formats: [
    {title: 'Headers', items: [
      {title: 'Header 1', format: 'h1'},
      {title: 'Header 2', format: 'h2'},
      {title: 'Header 3', format: 'h3'},
      {title: 'Header 4', format: 'h4'},
      {title: 'Header 5', format: 'h5'},
      {title: 'Header 6', format: 'h6'}]}
    {title: 'Paragraph', format: 'p'}
    {title: 'Table as Header', selector: 'table', classes: 'header_table'}
    {title: 'Infobox (1 column)', selector: 'table', classes: 'infobox_1_col'}
    {title: 'Infobox (2 columns)', selector: 'table', classes: 'infobox_2_col'}]
  content_css: [
    '/font-awesome/css/font-awesome.css?' + (new Date).getTime(),
    '/assets/tinymce.css?' + (new Date).getTime()]

heading = merge(common_settings,
  plugins:  'table directionality code paste'
  selector: 'textarea.heading'
  toolbar:  'undo redo paste removeformat code | table | ltr rtl'
  height:   '4em'
  body_id:  'tinymce_heading_instance')

text = merge(common_settings,
  plugins:  'table directionality lists autoheight uploadfile media link paste code'
  selector: 'textarea.text'
  toolbar:  'undo redo code paste removeformat      |
             styleselect bold italic underline      |
             table alignleft aligncenter alignright |
             bullist numlist outdent indent         |
             ltr rtl                                |
             link uploadfile media'
  body_id:  'tinymce_section_instance')

tinymce.init heading
tinymce.init text

# TODO: find a way around TinyMCE grabbing the even before we do...
# There may be a solution at https://wordpress.stackexchange.com/questions/167402/how-to-disable-tinymce-4-keyboard-shortcuts
$(window).bind 'keydown', (event) ->
  if event.ctrlKey or event.metaKey
    switch String.fromCharCode(event.which).toLowerCase()
      when 's'
        event.preventDefault()
        $('form.content_fragment').submit()
