heading = {
  statusbar: false,
  menubar: false,
  plugins: 'table directionality',
  selector: 'textarea.heading',
  toolbar: 'undo redo | table | ltr rtl | removeformat',
  height: '3.5em',
  branding: false}
  
tinymce.init heading

text = {
  statusbar: false,
  menubar: false,
  plugins: 'table directionality lists autoheight uploadfile media link',
  selector: 'textarea.text',
  toolbar: 'undo redo | formatselect bold italic underline | table alignleft aligncenter alignright | bullist numlist outdent indent | ltr rtl | link uploadfile media | removeformat',
  branding: false}
  
tinymce.init text
