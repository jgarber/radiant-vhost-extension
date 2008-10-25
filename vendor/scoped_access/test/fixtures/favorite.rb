class Favorite < ActiveRecord::Base
  belongs_to :member
  validates_presence_of :name, :member_id
end
