$(document).ready(function() {
  // Restore or initially set TOC state
  restore_toc_scrollbar_position();
  restore_toc_expansion_state();
  
  // Disable the top level links and make them open their parents' child <ul>.
  // An advantage of doing things in the below order is that clicking an 
  // already expanded section won't close it but just keep it open, which
  // I find preferable from a UI perspective.
  $('nav#sidebar li.level_1 > a').click(function(e) {
    // e.preventDefault();
    collapse_top_level_items();
    Cookies.set('textbookr_toc_scrollbar_expansion_state', $(this).parent().index());
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

function restore_toc_expansion_state() {
  // Only one top-level item is supposed to be expanded
  collapse_top_level_items();
  // Figure out which one it is and expand it
  state = Cookies.get('textbookr_toc_scrollbar_expansion_state');
  if (state) {child = parseInt(state) + 1} else {child = 1};
  $('nav#sidebar li.level_1:nth-child('+child+') > ul').show()
}
