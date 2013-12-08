#Hackerspace Monterrey Website.

###Requirements

- Ruby
- RubyGems
- Bundler

###Usage

Assuming you have RubyGems, install [Bundler](http://bundler.io).

	$ gem install bundler

Now clone the repository, the `--recursive` directive is used to also clone the
git submodule for [inuitcss](http://inuitcss.com) CSS framework.

	$ git clone --recursive https://github.com/hsmty/web.git hsmty.web
	$ cd hsmty.web
	$ bundle install

Run the `serve` task from `Rakefile.rb` to serve and watch any changes automatically.

	$ rake serve

Have fun.
