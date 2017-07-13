# https://gist.github.com/sheldonh/6089299
merge = (xs...) ->
  if xs?.length > 0
    tap {}, (m) -> m[k] = v for k, v of x for x in xs
tap = (o, fn) -> fn(o); o

common_settings =
  language_url: '/tinymce_langs/'+url('1')+'.js?' + (new Date).getTime()
  statusbar: false
  branding: false
  invalid_styles: 'height' 
  forced_root_block : ''
  force_p_newlines : true
  formats: [
#    TODO: figure out why these do nothing apparently?
#    bold: {inline: 'span', styles: {'font-weight', 'bold'}}
#    italic: {inline: 'span', styles: {'font-family', 'italic'}}
    removeformat: [
#      TODO: figure out whether there's a safe way of doing this...
#      {selector: 'td', attributes: ['rowspan', 'colspan'], split: false, expand: false, deep: true}
       {selector: '*', attributes: ['lang'], split: true, expand: true, deep: true}
    ]
  ]
  style_formats: [
    {title: 'Headers', items: [
      {title: 'Header 1', format: 'h1'},
      {title: 'Header 2', format: 'h2'},
      {title: 'Header 3', format: 'h3'},
      {title: 'Header 4', format: 'h4'},
      {title: 'Header 5', format: 'h5'},
      {title: 'Header 6', format: 'h6'}
    ]}
    {title: 'Table styles', items: [
      {title: 'Table used as header', selector: 'table', classes: 'header_table'}
      {title: 'Without header row', selector: 'table', classes: 'no_header_row'}
      {title: 'With full borders', selector: 'table', classes: 'full_border'}
      {title: 'Where the first cell has no border', selector: 'table', classes: 'first_cell_no_border'}
      {title: 'Without any borders', selector: 'table', classes: 'no_borders'}
      {title: 'Column width: 20%', selector: 'td', styles: {width: '20%'}}
      {title: 'Column width: 80%', selector: 'td', styles: {width: '80%'}}
    ]}
    {title: 'Languages', items: [
      {title: 'ܚܐܪܦܐܬ ܣܘܪܝܘܝܐ', selector: '*', attributes: {lang: 'syr'}}
      {title: 'English text', selector: '*', attributes: {lang: 'en'}}
    ]}
    {title: 'Standard paragraph', format: 'p'}
    {title: 'Infobox (for use on one-cell table)', selector: 'table', classes: 'infobox'}
    {title: 'Highlighted', inline: 'span', classes: 'highlight'}
    {title: 'Greyed out', inline: 'span', classes: 'greyed_out'}
  ]
  content_css: [
    '/font-awesome/css/font-awesome.css?' + (new Date).getTime(),
    '/assets/tinymce.css?' + (new Date).getTime()]

heading = merge(common_settings,
  menubar: false
  plugins:  'table directionality code paste'
  selector: 'textarea.heading'
  toolbar:  'undo redo paste removeformat code      |
             styleselect                            |
             table alignleft aligncenter alignright |
             ltr rtl'
  height:   '5.25em'
  body_id:  'tinymce_heading_instance')

text = merge(common_settings,
  menubar: false
  plugins:  'table directionality lists autoheight uploadfile media link paste code'
  selector: 'textarea.text'
  toolbar:  'undo redo code paste removeformat      |
             styleselect bold italic underline      |
             table alignleft aligncenter alignright |
             bullist numlist outdent indent         |
             ltr rtl                                |
             link unlink uploadfile media'
  body_id:  'tinymce_section_instance')

tinymce.init heading
tinymce.init text

# TODO: find a way around TinyMCE grabbing the event before we do...
# There may be a solution at https://wordpress.stackexchange.com/questions/167402/how-to-disable-tinymce-4-keyboard-shortcuts
$(window).bind 'keydown', (event) ->
  if event.ctrlKey or event.metaKey
    switch String.fromCharCode(event.which).toLowerCase()
      when 's'
        event.preventDefault()
        $('form.content_fragment').submit()
