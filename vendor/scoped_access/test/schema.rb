ActiveRecord::Schema.define(:version => 2) do

  create_table :groups, :force => true do |t|
    t.column :name,    :string
    t.column :deleted, :boolean, :default=>0
  end

  create_table :members, :force => true do |t|
    t.column :name,    :string
    t.column :grade,   :integer
    t.column :deleted, :boolean, :default=>0
    t.column :group_id,:integer
  end

  create_table :favorites, :force => true do |t|
    t.column :name,     :string
    t.column :member_id,:integer
  end

end
