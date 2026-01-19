module PublicIdGeneratable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_public_id, on: :create
    validates :public_id, presence: true, uniqueness: true, length: { is: 20 }
  end

  private
    def generate_public_id
      self.public_id ||= SecureRandom.alphanumeric(20).downcase
    end
end
