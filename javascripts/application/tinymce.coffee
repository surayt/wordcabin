# https://gist.github.com/sheldonh/6089299
merge = (xs...) ->
  if xs?.length > 0
    tap {}, (m) -> m[k] = v for k, v of x for x in xs
tap = (o, fn) -> fn(o); o

ui_locale = $('html').data('ui-locale') || url('1')

common_settings =

  # Having to specify a language_url unfortunately means that plugin
  # lang files can't be used and so their contents must be appended to
  # the global lang files instead.
  language_url: "/tinymce_langs/#{ui_locale}.js?#{(new Date).getTime()}"
  language: ui_locale
  
  statusbar: false
  branding: false
  object_resizing: false
  invalid_styles: 'height' 
  forced_root_block : ''
  force_p_newlines : true
  
  formats:
    removeformat: [
      {selector: 'h1,h2,h3,h4,b,strong,em,i,font,u,strike,span', remove: 'all', split: true, expand: false, block_expand: true, deep: true}
      {selector: '*', attributes: ['style', 'class', 'lang', 'dir', 'colspan', 'rowspan'], split: false, expand: false, deep: true}
    ]
    
  style_formats: [
    {title: 'Headlines (2nd order and below)', items: [
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
      {title: 'With full vertical borders', selector: 'table', classes: 'vertical_borders'}
      {title: 'Table width: 50%', selector: 'table', classes: 'width_50_percent'}
      {title: 'Table width: 80%', selector: 'table', classes: 'width_80_percent'}
      {title: '2-column table (default column width: 50%)', selector: 'table', classes: 'two_columns'}
      {title: '3-column table (default column width: 33%)', selector: 'table', classes: 'three_columns'}
      {title: '4-column table (default column width: 25%)', selector: 'table', classes: 'four_columns'}
      {title: '5-column table (default column width: 20%)', selector: 'table', classes: 'five_columns'}
      {title: '6-column table (default column width: 16%)', selector: 'table', classes: 'six_columns'}
      {title: '7-column table (default column width: 14%)', selector: 'table', classes: 'seven_columns'}
      {title: 'Column width: 5%', selector: 'td', classes: 'width_5_percent'}
      {title: 'Column width: 20%', selector: 'td', classes: 'width_20_percent'}
      {title: 'Column width: 30%', selector: 'td', classes: 'width_30_percent'}
      {title: 'Column width: 50%', selector: 'td', classes: 'width_50_percent'}
      {title: 'Column width: 80%', selector: 'td', classes: 'width_80_percent'}
    ]}
    {title: 'Languages', items: [
      {title: 'English (the whole containing element)', selector: '*', attributes: {lang: 'en'}}
      {title: 'English (just the selected text)', inline: 'span', attributes: {dir: 'ltr', lang: 'en'}}
      {title: '(ܣܘܪܝܬ (ܐܘ ܡܩܛܥ ܟܐܡܝܠܐ', selector: '*', attributes: {lang: 'syr'}}
      {title: 'ܣܘܪܝܬ (ܑܐܘ ܟ݂ܒܪܐ ܡܢܩܝܐ ܒܣ)', inline: 'span', attributes: {dir: 'rtl', lang: 'syr'}}
    ]}
    {title: 'Images', items: [
      {title: 'Width:   5%', selector: 'img', classes: 'width_5_percent'}
      {title: 'Width:  20%', selector: 'img', classes: 'width_20_percent'}
      {title: 'Width:  50%', selector: 'img', classes: 'width_50_percent'}
      {title: 'Width:  80%', selector: 'img', classes: 'width_80_percent'}
      {title: 'Width: 100%', selector: 'img', classes: 'width_100_percent'}
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
  menubar:  false
  plugins:  'table directionality code paste'
  selector: 'textarea.heading'
  toolbar:  'undo redo code paste removeformat      |
             styleselect                            |
             table alignleft aligncenter alignright'
  height:   '5.25em'
  body_id:  'tinymce_heading_instance')

text = merge(common_settings,
  menubar:  false
  plugins:  'table directionality lists media link paste code image autoheight uploadfile insertexercise'
  selector: 'textarea.text'
  toolbar:  'undo redo code paste removeformat      |
             styleselect bold italic underline      |
             table alignleft aligncenter alignright |
             bullist numlist outdent indent         |
             link unlink image media insertexercise uploadfile'
  body_id:  'tinymce_section_instance')
  
name = merge(common_settings,
  menubar:  false
  plugins:  'directionality code paste'
  selector: 'textarea.name'
  toolbar:  'undo redo code paste removeformat'
  height:   '5.25em'
  body_id:  'tinymce_name_instance')
  
html = merge(common_settings,
  menubar:  false
  plugins:  'table directionality lists media link paste code image uploadfile insertexercise'
  selector: 'textarea.html'
  toolbar:  'undo redo code paste removeformat      |
             styleselect bold italic underline      |
             table alignleft aligncenter alignright |
             bullist numlist outdent indent         |
             link unlink image media uploadfile'
  height:   '450px'
  body_id:  'tinymce_html_instance')
  
console.log "tinymce heading editor"
tinymce.init heading
console.log "tinymce text editor"
tinymce.init text

console.log "tinymce name editor"
tinymce.init name
console.log "tinymce html editor"
tinymce.init html

# TODO: find a way around TinyMCE grabbing the event before we do...
# There may be a solution at https://wordpress.stackexchange.com/questions/167402/how-to-disable-tinymce-4-keyboard-shortcuts
$(window).bind 'keydown', (event) ->
  if event.ctrlKey or event.metaKey
    switch String.fromCharCode(event.which).toLowerCase()
      when 's'
        event.preventDefault()
        $('form.content_fragment, form.exercise_type').submit()
