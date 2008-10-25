class Admin::SiteController < Admin::AbstractModelController
  model_class Site
  
  only_allow_access_to :index, :new, :edit, :remove, :when => :admin,
    :denied_url => {:controller => 'page', :action => :index},
    :denied_message => 'You must have administrative privileges to perform this action.'
  
  def new
    @site = Site.new
    if handle_new_or_edit_post
      render :template => "admin/site/edit"
    else
      @site.pages << Page.new(:slug => '/', :title => 'Home Page', :breadcrumb => 'Home', :status_id => Status[:published].id)
      @site.save
    end
  end
  
end
