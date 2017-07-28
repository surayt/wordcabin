About Wordcabin
===============

Wordcabin is a Ruby/Sinatra web application for writing and maintaining HTML-based interactive textbooks. It was created for the Aramaic Online Project's Surayt online course. It features an editorial view where a book can be put together from so-called content fragments.

Prerequisites
=============

On Solus OS
-----------

```
sudo eopkg install -c system.devel
sudo eopkg install ruby ruby-devel nodejs sqlite3
```

On Debian-based distributions
-----------------------------

```
sudo apt install build-essential ruby ruby-dev rubygems nodejs sqlite3
```

Setup
=====

After cloning the `wordcabin` repository, you need to add a project. At the moment, there is only the Aramaic Online Project's textbook.

- First, create a `data` folder: `mkdir data`
- For the next step, [Git Large File Storage](https://git-lfs.github.com/) must be installed.
- Inside of the `data` folder, clone the AOP textbook repository: `cd data; git clone git@git.weitnahbei.de:aop/data.git aop`. Be aware this will result in a ~450MB download of a few thousand files, mostly very small MP3 files. If the download gets interrupted or otherwise fails, it can be restarted doing `cd aop; git lfs pull`.
- For the next step, [Ruby](https://www.ruby-lang.org/en/) will need to be installed in Version 2.2 at the least, including development files (for compiling native extensions of required libraries) and the most recent version of [RubyGems](https://rubygems.org/). All three are usually installed via your distribution's package manager (see prerequisites section above). With some distributions, development tools will need to be installed manually as well.
- Install [Node.js](https://nodejs.org/en/) manually or via the package manager.
- Now, `gem install bundler` (or `sudo gem install bundler`, depending on how your system is setup), followed by `bundle install` will install the libraries required by *wordcabin*. If any Gem fails to install, read the error message attentively as it will often contain instructions on what course of action might solve the problem.
- Run `git submodule init` followed by `git submodule update` to download TinyMCE and other JavaScript/CSS components.
- Run `rake db:schema:load` to initialize the database specified in `config/database.yml` and `rake db:seed` to add an admin user (edit `config/seed.rb` beforehand to change that user's email and password).
- Now start the application server on the port specified in `config/config.rb` (the default being 4567) by running `rake` without any further arguments. If the server comes up without error, you should be able to access the configured project.
