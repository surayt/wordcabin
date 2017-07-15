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
  formats:
    removeformat: [
      {selector: 'h1,h2,h3,h4,b,strong,em,i,font,u,strike,span', remove: 'all', split: true, expand: false, block_expand: true, deep: true}
      {selector: '*', attributes: ['style', 'class', 'lang', 'dir', 'colspan', 'rowspan'], split: false, expand: false, deep: true}
    ]
  style_formats: [
    {title: 'Überschriften (für 1. Ordnung oberen Editor benutzen)', items: [
      {title: '2. Ordnung (ohne Tabelle)', format: 'h2'},
      {title: '3. Ordnung (ohne Tabelle)', format: 'h3'},
      {title: '4. Ordnung (ohne Tabelle)', format: 'h4'},
      {title: '2. Ordnung (für Verwendung mit Tabelle)', selector: 'table', classes: 'header_table h2'}
      {title: '3. Ordnung (für Verwendung mit Tabelle)', selector: 'table', classes: 'header_table h3'}
      {title: '4. Ordnung (für Verwendung mit Tabelle)', selector: 'table', classes: 'header_table h4'}
    ]}
    {title: 'Infoboxes (for use on one-cell table)', items: [
      {title: 'Information', selector: 'table', classes: 'infobox notice'}
      {title: 'Culture', selector: 'table', classes: 'infobox culture'}
      {title: 'Grammar', selector: 'table', classes: 'infobox grammar'}
    ]}
    {title: 'Tables', items: [
      {title: 'Without header row', selector: 'table', classes: 'no_header_row'}
      {title: 'With full borders', selector: 'table', classes: 'full_border'}
      {title: 'Where the first cell has no border', selector: 'table', classes: 'first_cell_no_border'}
      {title: 'Without any borders', selector: 'table', classes: 'no_borders'}
      {title: 'Table width: 50%', selector: 'table', classes: 'width_50_percent'}
      {title: 'Table width: 80%', selector: 'table', classes: 'width_80_percent'}
      {title: 'Column width: 20%', selector: 'td', classes: 'width_20_percent'}
      {title: 'Column width: 50%', selector: 'td', classes: 'width_50_percent'}
      {title: 'Column width: 80%', selector: 'td', classes: 'width_80_percent'}
    ]}
    {title: 'Languages', items: [
      {title: 'English (the whole containing element)', selector: '*', attributes: {lang: 'en'}}
      {title: 'English (just the selected text)', inline: 'span', attributes: {dir: 'ltr', lang: 'en'}}
      {title: '(ܣܘܪܝܬ (ܐܘ ܡܩܛܥ ܟܐܡܝܠܐ', selector: '*', attributes: {lang: 'syr'}}
      {title: 'ܣܘܪܝܬ (ܑܐܘ ܟ݂ܒܪܐ ܡܢܩܝܐ ܒܣ)', inline: 'span', attributes: {dir: 'rtl', lang: 'syr'}}
    ]}
    {title: 'Standard paragraph', format: 'p'}
    {title: 'Highlighted', inline: 'span', classes: 'highlight'}
    {title: 'Greyed out', inline: 'span', classes: 'greyed_out'}
    {title: 'Light-grey background', selector: '*', classes: 'grey_background'}
  ]
  content_css: [
    '/font-awesome/css/font-awesome.css?' + (new Date).getTime(),
    '/assets/tinymce.css?' + (new Date).getTime()]

heading = merge(common_settings,
  menubar: false
  plugins:  'table directionality code paste'
  selector: 'textarea.heading'
  toolbar:  'undo redo code paste removeformat      |
             styleselect                            |
             table alignleft aligncenter alignright'
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
