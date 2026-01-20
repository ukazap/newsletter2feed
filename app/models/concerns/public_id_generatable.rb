module PublicIdGeneratable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_public_id, on: :create
    validates :public_id, presence: true, uniqueness: true, length: { is: 36 }, on: :create
  end

  private
    def generate_public_id
      self.public_id ||= SecureRandom.uuid_v7
    end
end
