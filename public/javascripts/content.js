var config = {};

config = $.extend(config, {
  resize: false,
  width: '100%',
  height: '100%',
  autoresize: true,
  selector: 'div#content textarea',
  removed_menuitems: 'newdocument',
  plugins: 'table save',
  statusbar: false,
  toolbar: 'save | undo redo | styleselect | bold italic | alignleft aligncenter alignright | bullist numlist outdent indent'
});

function resize() {
  setTimeout(function () {
    // Main container
    var max = $('.mce-tinymce')
              .css('border', 'none')
              .parent().outerHeight();
    // Menubar
    max += -$('.mce-menubar.mce-toolbar').outerHeight();
    // Toolbar
    max -= $('.mce-toolbar-grp').outerHeight();
    // Random fix lawl - why 1px? no one knows
    max -= 45;
    // Set the new height
    $('.mce-edit-area').height(max);
  }, 200);
}

$(window).on('resize', function () {
  resize();
});

config.init_instance_callback = function (editor) {
  resize();
};

tinymce.init(config);
