(function() {
  var add_content_fragment_delete_links, collapse_top_level_items, make_sidebar_resizable, make_toc_expandable, restore_toc_expansion_state, restore_toc_scrollbar_position;

  make_toc_expandable = function() {
    $('nav#sidebar li.level_1 > a').click(function(e) {
      collapse_top_level_items();
      Cookies.set('wordcabin_toc_scrollbar_expansion_state', $(this).parent().index());
      $(this).parent().children('ul').toggle();
    });
    return $('nav#sidebar li.level_2 a').click(function(e) {
      Cookies.set('wordcabin_toc_scrollbar_position', $('nav#sidebar').scrollTop());
    });
  };

  collapse_top_level_items = function() {
    $('nav#sidebar li.level_1 > ul').hide();
  };

  restore_toc_scrollbar_position = function() {
    var pos;
    pos = Cookies.get('wordcabin_toc_scrollbar_position');
    $('nav#sidebar').scrollTop(pos || 0);
  };

  restore_toc_expansion_state = function() {
    var child, state;
    collapse_top_level_items();
    state = Cookies.get('wordcabin_toc_scrollbar_expansion_state');
    if (state) {
      child = parseInt(state) + 1;
    } else {
      child = 1;
    }
    $('nav#sidebar li.level_1:nth-child(' + child + ') > ul').show();
  };

  make_sidebar_resizable = function() {
    var mainmin, max, min;
    min = 100;
    max = 3600;
    mainmin = 200;
    $('#divider').mousedown(function(e) {
      e.preventDefault();
      $(document).mousemove(function(e) {
        var x;
        e.preventDefault();
        x = e.pageX - ($('#sidebar').offset().left);
        if (x > min && x < max && e.pageX < $(window).width() - mainmin) {
          $('#sidebar').css('width', x);
          $('#content').css('margin-left', x);
        }
      });
    });
    return $(document).mouseup(function(e) {
      $(document).unbind('mousemove');
    });
  };

  add_content_fragment_delete_links = function() {
    return $('body.editor #sidebar ul li a').each(function() {
      var href;
      href = $(this).attr('href');
      return $(this).append('&nbsp;<a href="' + href + '" class="btn delete" data-method="delete"><i class="fa fa-trash"></i></a>');
    });
  };

  $(document).ready(function() {
    make_sidebar_resizable();
    restore_toc_scrollbar_position();
    restore_toc_expansion_state();
    make_toc_expandable();
    add_content_fragment_delete_links();
  });

}).call(this);
