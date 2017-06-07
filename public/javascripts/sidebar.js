(function() {
  var collapse_top_level_items, restore_toc_expansion_state, restore_toc_scrollbar_position;

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

  $(document).ready(function() {
    restore_toc_scrollbar_position();
    restore_toc_expansion_state();
    $('nav#sidebar li.level_1 > a').click(function(e) {
      collapse_top_level_items();
      Cookies.set('wordcabin_toc_scrollbar_expansion_state', $(this).parent().index());
      $(this).parent().children('ul').toggle();
    });
    $('nav#sidebar li.level_2 a').click(function(e) {
      Cookies.set('wordcabin_toc_scrollbar_position', $('nav#sidebar').scrollTop());
    });
  });

}).call(this);
