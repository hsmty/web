task :serve do
  Signal.trap :SIGINT do
    exit
  end

  exec 'bundle exec sass _style/style.scss:css/style.min.css --style compressed --watch' if Process.fork.nil?
  exec 'bundle exec jekyll serve --watch --drafts' if Process.fork.nil?
  Process.wait
end
