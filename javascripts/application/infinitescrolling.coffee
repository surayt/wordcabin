$(document).ready ->
  $('.articles').infiniteScroll
    path: 'nav a.next'
    append: 'article'
    history: false
