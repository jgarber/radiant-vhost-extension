class Song < ActiveRecord::Base
  belongs_to :group
  validates_presence_of :name, :content, :group_id
end
