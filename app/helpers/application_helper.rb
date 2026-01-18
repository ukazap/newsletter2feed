module ApplicationHelper
  def sanitize_email(html)
    doc = Nokogiri::HTML.fragment(html)
    doc.css("style").remove
    sanitize(doc.to_html)
  end
end
