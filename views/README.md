# Set-up of the view files

The templating system used is [HAML](http://haml.info/), which compiles directly into HTML but is easier to type and read. The view files are set-up to coincide with the general application set-up as much as possible. To get started, look at `layout.haml` first and know that the `yield` keyword inside of it is where other files in the root `views/` folder (i.e., `session.haml`, `index.haml`, and so on) will be included at.
