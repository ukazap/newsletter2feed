class AtomFeedBuilder
  ATOM_NAMESPACE = "http://www.w3.org/2005/Atom"

  def initialize(feed)
    @feed = feed
  end

  def to_xml
    builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      xml.feed(xmlns: ATOM_NAMESPACE) do
        build_feed_metadata(xml)
        build_entries(xml)
      end
    end

    builder.to_xml
  end

  private

  def build_feed_metadata(xml)
    xml.id { xml.text(feed_urn) }
    xml.title { xml.text(@feed.title) }
    xml.updated { xml.text(last_updated.iso8601) }
    xml.link(rel: "self", type: "application/atom+xml", href: @feed.feed_url)
    xml.link(rel: "alternate", type: "text/html", href: feed_html_url)

    if @feed.icon.present?
      xml.icon { xml.text(@feed.icon) }
    end
  end

  def build_entries(xml)
    @feed.feed_entries.order(created_at: :desc).each do |entry|
      build_entry(xml, entry)
    end
  end

  def build_entry(xml, entry)
    xml.entry do
      xml.id { xml.text(entry_urn(entry)) }
      xml.title { xml.text(entry.title) }
      xml.updated { xml.text(entry.updated_at.iso8601) }
      xml.published { xml.text(entry.created_at.iso8601) }

      if entry.author.present?
        xml.author do
          xml.name { xml.text(entry.author) }
        end
      end

      xml.link(rel: "alternate", type: "text/html", href: entry.entry_url)
      xml.content(type: "html") { xml.text(entry.content_with_footer) }

      build_enclosures(xml, entry)
    end
  end

  def build_enclosures(xml, entry)
    entry.enclosures.each do |enclosure|
      xml.link(
        rel: "enclosure",
        type: enclosure.content_type,
        length: enclosure.byte_size,
        href: enclosure_url(enclosure)
      )
    end
  end

  def feed_urn
    "urn:newsletter2feed:feed:#{@feed.public_id}"
  end

  def entry_urn(entry)
    "urn:newsletter2feed:entry:#{entry.public_id}"
  end

  def last_updated
    @feed.feed_entries.maximum(:updated_at) || @feed.updated_at
  end

  def feed_html_url
    Rails.application.routes.url_helpers.feed_url(
      @feed.public_id,
      host: Rails.configuration.app_hostname
    )
  end

  def enclosure_url(enclosure)
    Rails.application.routes.url_helpers.rails_blob_url(
      enclosure,
      host: Rails.configuration.app_hostname
    )
  end
end
