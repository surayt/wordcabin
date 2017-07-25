Contributing
~~~~~~~~~~~~

After cloning the `wordcabin` repository, you need to add a project. At the moment, there is only the Aramaic Online Project's textbook.

- First, create a `data` folder: `mkdir data`
- For the next step, [Git Large File Storage](https://git-lfs.github.com/) must be installed.
- Inside of the `data` folder, clone the AOP textbook repository: `cd data; git clone git@git.weitnahbei.de:aop/data.git aop`. Be aware this will result in a ~450MB download of a few thousand files, mostly very small MP3 files. If the download gets interrupted or otherwise fails, it can be restarted doing `cd aop; git lfs pull`.
- For the next step, [Ruby](https://www.ruby-lang.org/en/) will need to be installed in Version 2.2 at the least, including development files (for compiling native extensions of required libraries) and the most recent version of [RubyGems](https://rubygems.org/). All three are usually installed via your distribution's package manager. Note that with some distributions, development tools will need to be installed manually as well.
- Now, `gem install bundler` (or `sudo gem install bundler`, depending on how your system is setup), followed by `bundle install` will install the libraries required by *wordcabin*. If any Gem fails to install, read the error message attentively as it will often contain instructions on what course of action might solve the problem.
- Run `git submodule init` followed by `git submodule update` to download TinyMCE and other JavaScript/CSS components.
- Run `rake db:schema:load` to initialize the database specified in `config/database.yml`
- Now start the application server on the port specified in `config/config.rb` (the default being 4567) by running `rake` without any further arguments. If the server comes up without error, you should be able to access the configured project.
