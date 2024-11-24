# frozen_string_literal: true

class UserSite < ApplicationRecord
  belongs_to :user
  belongs_to :site

  validates :user_id, uniqueness: { scope: :site_id, message: 'já está associado a este site.' }
end
