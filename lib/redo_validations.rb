class Page
  # Clear out existing validations
  write_inheritable_attribute(:validate, [])
  
  # Validations
  validates_presence_of :title, :slug, :breadcrumb, :status_id, :message => 'required'
  
  validates_length_of :title, :maximum => 255, :message => '%d-character limit'
  validates_length_of :slug, :maximum => 100, :message => '%d-character limit'
  validates_length_of :breadcrumb, :maximum => 160, :message => '%d-character limit'
  
  validates_format_of :slug, :with => %r{^([-_.A-Za-z0-9]*|/)$}, :message => 'invalid format'  
  validates_uniqueness_of :slug, :scope => [:parent_id, :site_id], :message => 'slug already in use for child of parent'
  validates_numericality_of :id, :status_id, :parent_id, :allow_nil => true, :only_integer => true, :message => 'must be a number'
  
  validate :valid_class_name
  
  validates_presence_of :site_id
end

class Snippet
  # Clear out existing validations
  write_inheritable_attribute(:validate, [])

  # Validations
  validates_presence_of :name, :message => 'required'
  validates_length_of :name, :maximum => 100, :message => '%d-character limit'
  validates_length_of :filter_id, :maximum => 25, :allow_nil => true, :message => '%d-character limit'
  validates_format_of :name, :with => %r{^\S*$}, :message => 'cannot contain spaces or tabs'
  validates_uniqueness_of :name, :message => 'name already in use', :scope => :site_id
  
  validates_presence_of :site_id
  
end

class Layout
  # Clear out existing validations
  write_inheritable_attribute(:validate, [])

  # Validations
  validates_presence_of :name, :message => 'required'
  validates_uniqueness_of :name, :message => 'name already in use', :scope => :site_id
  validates_length_of :name, :maximum => 100, :message => '%d-character limit'
  
  validates_presence_of :site_id
  
end
