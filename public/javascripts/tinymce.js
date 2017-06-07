(function() {
  var config, resize;

  config = {};

  resize = function() {
    setTimeout((function() {
      var max;
      max = $('.mce-tinymce').css('border', 'none').parent().outerHeight();
      max += -$('.mce-menubar.mce-toolbar').outerHeight();
      max -= $('.mce-toolbar-grp').outerHeight();
      max -= 45;
      $('.mce-edit-area').height(max);
    }), 200);
  };

  config = $.extend(config, {
    resize: false,
    width: '100%',
    height: '100%',
    autoresize: true,
    selector: 'div#content textarea',
    removed_menuitems: 'newdocument',
    plugins: 'table save directionality',
    statusbar: false,
    toolbar: 'save | undo redo | bold italic | alignleft aligncenter alignright | bullist numlist outdent indent | ltr rtl'
  });

  $(window).on('resize', function() {
    resize();
  });

  config.init_instance_callback = function(editor) {
    resize();
  };

  tinymce.init(config);

}).call(this);
