module FrancisCms
  class Note < ActiveRecord::Base
    extend FriendlyId
    include FrancisCms::Concerns::Models::Publishable
    include FrancisCms::Concerns::Models::Redcarpeted
    include FrancisCms::Concerns::Models::Syndicatable
    include FrancisCms::Concerns::Models::Taggable
    include FrancisCms::Concerns::Models::Webmentionable

    validates :slug, :body, presence: true

    friendly_id :id
    redcarpet :body

    self.per_page = 10
  end
end