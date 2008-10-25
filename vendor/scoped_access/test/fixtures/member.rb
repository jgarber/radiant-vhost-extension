class Member < ActiveRecord::Base
  belongs_to :group
  has_many   :favorites, :dependent=>true
  validates_presence_of :yomi, :name, :comments, :group_id
end
