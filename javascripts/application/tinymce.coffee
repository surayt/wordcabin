# https://gist.github.com/sheldonh/6089299
merge = (xs...) ->
  if xs?.length > 0
    tap {}, (m) -> m[k] = v for k, v of x for x in xs
tap = (o, fn) -> fn(o); o

common_settings =
  statusbar: false
  menubar: false
  branding: false
  invalid_styles: 'height' 
  forced_root_block : ''
  force_p_newlines : true
  style_formats: [
    {title: 'Headers', items: [
      {title: 'Header 1', format: 'h1'},
      {title: 'Header 2', format: 'h2'},
      {title: 'Header 3', format: 'h3'},
      {title: 'Header 4', format: 'h4'},
      {title: 'Header 5', format: 'h5'},
      {title: 'Header 6', format: 'h6'}]}
    {title: 'Paragraph', format: 'p'}
    {title: 'Table as header', selector: 'table', classes: 'header_table'}
    {title: 'Table with no header row', selector: 'table', classes: 'no_header_row'}
    {title: 'Table with full borders', selector: 'table', classes: 'full_border'}
    {title: 'Table where first cell has no border', selector: 'table', classes: 'first_cell_no_border'}
    {title: 'Table without any borders', selector: 'table', classes: 'no_borders'}
    {title: 'Column width: 20%', selector: 'td', styles: {width: '20%'}}
    {title: 'Infobox', selector: 'table', classes: 'infobox'}
    {title: 'ܚܐܪܦܐܬ ܣܘܪܝܘܝܐ', inline: 'span', classes: 'syriac'}
    {title: 'Latin letters', inline: 'span', classes: 'latin'}
    {title: 'Highlighted', inline: 'span', classes: 'highlighted'}
    {title: 'Greyed out', inline: 'span', classes: 'greyed_out'}
  ]
  content_css: [
    '/font-awesome/css/font-awesome.css?' + (new Date).getTime(),
    '/assets/tinymce.css?' + (new Date).getTime()]

heading = merge(common_settings,
  plugins:  'table directionality code paste'
  selector: 'textarea.heading'
  toolbar:  'undo redo paste removeformat code | table | ltr rtl'
  height:   '5.25em'
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
