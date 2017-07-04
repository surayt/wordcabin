$(document).ready ->
  $('body.user main.articles').infiniteScroll
    path: 'nav a.next'
    append: 'article'
    history: false
