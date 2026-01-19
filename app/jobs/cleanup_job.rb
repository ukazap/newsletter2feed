class CleanupJob < ApplicationJob
  queue_as :default

  def perform
    cleanup_old_hits
    cleanup_orphaned_blobs
  end

  private
    def cleanup_old_hits
      deleted_count = FeedHit.cleanup_old!
      Rails.logger.info("CleanupJob: Deleted #{deleted_count} old feed hits")
    end

    def cleanup_orphaned_blobs
      ActiveStorage::Blob.unattached.where("created_at < ?", 1.day.ago).find_each(&:purge_later)
    end
end
