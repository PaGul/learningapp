def full_title (title)
  btitle = "Ruby on Rails Tutorial Sample App"
  if title==""
    btitle
  else
    "#{btitle} | #{title}"
  end
end