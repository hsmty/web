task :default => [:development]

desc "Start Jekyll and Compass in watch mode."
task :development do
	Signal.trap :SIGINT do
		exit
	end

	exec 'bundle exec compass watch _style _style/style.scss' if Process.fork.nil?
	exec 'bundle exec jekyll serve --watch --drafts --config _config.yml,_config_dev.yml' if Process.fork.nil?
	Process.wait
end

desc "Generate CSS with Compass, static site with Jekyll and deploy it."
task :deploy do
	system 'bundle exec compass compile _style _style/style.scss'
	system 'bundle exec jekyll build'
	# Move files from _site to web root.
end
