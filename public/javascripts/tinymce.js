(function() {
  var heading, text;

  heading = {
    statusbar: false,
    menubar: false,
    plugins: 'table directionality',
    selector: 'textarea.heading',
    toolbar: 'undo redo | table | ltr rtl | removeformat',
    height: '3.5em'
  };

  tinymce.init(heading);

  text = {
    statusbar: false,
    menubar: false,
    plugins: 'table directionality lists autoheight media',
    selector: 'textarea.text',
    toolbar: 'undo redo | formatselect bold italic underline | table alignleft aligncenter alignright | bullist numlist outdent indent | ltr rtl | removeformat | media'
  };

  tinymce.init(text);

}).call(this);
