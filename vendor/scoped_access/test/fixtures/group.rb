class Group < ActiveRecord::Base
  has_many :members, :include=>"favorites", :order=>"members", :dependent=>true
  validates_presence_of :name
end
