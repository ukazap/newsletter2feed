class NewslettersMailbox < ApplicationMailbox
  BLOCKED_AGGREGATORS = %w[
    blogtrottr.com
    feedrabbit.com
    feedblitz.com
  ].freeze

  before_processing :find_feed
  before_processing :check_aggregator

  def process
    entry = @feed.feed_entries.create!(
      author: extract_author,
      title: extract_title,
      content: extract_content
    )

    attach_enclosures(entry)
    @feed.prune_entries!
  end

  private
    def find_feed
      recipient = mail.recipients.find { |r| r.match?(/\A[a-z0-9]{20}@/i) }
      @feed = Feed.find_by_email(recipient)

      unless @feed
        bounced!
      end
    end

    def check_aggregator
      from_address = mail.from&.first&.downcase || ""

      if BLOCKED_AGGREGATORS.any? { |domain| from_address.end_with?("@#{domain}") }
        bounced!
      end
    end

    def extract_author
      if mail[:from]&.display_names&.first.present?
        mail[:from].display_names.first
      else
        mail.from&.first
      end
    end

    def extract_title
      mail.subject.presence || "Untitled"
    end

    def extract_content
      if mail.html_part
        mail.html_part.decoded
      elsif mail.text_part
        "<pre>#{ERB::Util.html_escape(mail.text_part.decoded)}</pre>"
      elsif mail.content_type&.include?("text/html")
        mail.decoded
      else
        "<pre>#{ERB::Util.html_escape(mail.decoded)}</pre>"
      end
    rescue => e
      Rails.logger.error("Error extracting email content: #{e.message}")
      "<p>Unable to extract email content</p>"
    end

    def attach_enclosures(entry)
      mail.attachments.each do |attachment|
        entry.enclosures.attach(
          io: StringIO.new(attachment.decoded),
          filename: attachment.filename,
          content_type: attachment.content_type
        )
      end
    end
end
