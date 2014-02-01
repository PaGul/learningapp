module ApplicationHelper
  def full_title (title)
    btitle = "Ruby on Rails Tutorial Sample App"
    if title.empty?
      btitle
    else
      "#{btitle} | #{title}"
    end
  end
end
