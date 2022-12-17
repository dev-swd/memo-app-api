class Content < ApplicationRecord
  has_many :tags, dependent: :destroy
end
