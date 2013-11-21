task :serve do
  %x(bundle exec sass _style/style.scss:css/style.min.css --style compressed)
  #%x(bundle exec sass _style/style.scss:css/style.css --style expanded)
	exec('bundle exec jekyll serve --watch --drafts')
end

