$(document).ready(function() {
  // Only show the first top level item's children when page opens
  collapse_top_level_items();
  $('nav#sidebar li.level_1:first-child > ul').show()
  
  // Also, disable the top level links (we only want to use them to expand the lower levels)
  $('nav#sidebar li.level_1 > a').click(function(e) {
    e.preventDefault();
    collapse_top_level_items();
    $(this).parent().children('ul').toggle();
  });
});

function collapse_top_level_items() {
  $('nav#sidebar li.level_1 > ul').hide();
}
