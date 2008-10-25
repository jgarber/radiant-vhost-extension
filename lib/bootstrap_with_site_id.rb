module BootstrapWithSiteId
  def load_database_template_with_site_id(filename)
    template = nil
    if filename
      name = find_template_in_path(filename)
      unless name
        announce "Invalid template name: #{filename}"
        filename = nil
      else
        template = load_template_file(name)
      end
    end
    unless filename
      templates = find_and_load_templates("#{RAILS_ROOT}/vendor/extensions/vhost/db/templates/*.yml")
      templates.concat find_and_load_templates("#{RAILS_ROOT}/db/templates/*.yml") if RADIANT_ROOT != RAILS_ROOT
      choose do |menu|
        menu.header = "\nSelect a database template"
        menu.prompt = "[1-#{templates.size}]: "
        menu.select_by = :index
        templates.each { |t| menu.choice(t['name']) { template = t } }
      end
    end
    create_records(template)
  end
end