$(document).ready(function() {
  // Restore TOC scrollbar position from cookie, if present
  restore_toc_scrollbar_position();

  // Only show the first top level item's children when page opens.
  collapse_top_level_items();
  $('nav#sidebar li.level_1:first-child > ul').show()
  
  // Disable the top level links and make them open their parents' child <ul>.
  // An advantage of doing things in the below order is that clicking an 
  // already expanded section won't close it but just keep it open, which
  // I find preferable from a UI perspective.
  $('nav#sidebar li.level_1 > a').click(function(e) {
    e.preventDefault();
    collapse_top_level_items();
    $(this).parent().children('ul').toggle();
  });
  
  // Cause second and third level links to save the TOC scrollbar position
  // to a cookie so it may be restored upon the page being loaded again.
  $('nav#sidebar li.level_2 a').click(function(e) {
    Cookies.set('textbookr_toc_scrollbar_position', $('nav#sidebar').scrollTop());    
  });
});

function collapse_top_level_items() {
  $('nav#sidebar li.level_1 > ul').hide();
}

function restore_toc_scrollbar_position() {
  pos = Cookies.get('textbookr_toc_scrollbar_position')
  $('nav#sidebar').scrollTop(pos || 0);
}
