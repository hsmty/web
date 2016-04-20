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

desc "Create a new post and open it in the default $EDITOR"
task :edit do
  post_args = {:title => ENV["title"]}

  if post_args[:title].nil? then 
    puts "Usage: rake edit title=\"Your post title\""
    exit
  end
  
  post_date = Time.now.strftime("%Y-%m-%d")
  post_file_title = post_args[:title].downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '') 
  post_file = File.join [File.dirname(__FILE__), '_posts', "#{post_date}-#{post_file_title}.md"]
  
  File.open(post_file, 'w') do |file|
    file.write %{---
layout: post
title: #{post_args[:title]}
author: Your Name
excerpt: One line description of the content of this post
---
This is the content for your new post: #{post_args[:title]}
The lines above the following marker will appear in the front page and the full post view.
<!--more-->
The lines below the marker will only appear in the full post view
Now, get to writing
}
  end unless File.exist?(post_file)
  puts "Opening #{post_file} with your default editor"
  system "#{ENV["EDITOR"]} #{post_file}"
end