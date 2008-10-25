require File.dirname(__FILE__) + '/../test_helper'
require_dependency 'site_controller'

# Re-raise errors caught by the controller.
class SiteController; def rescue_action(e) raise e end; end

class VhostExtensionTest < Test::Unit::TestCase
  fixtures :pages, :page_parts, :sites
  test_helper :pages
  
  def setup
    @controller = SiteController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @cache      = @controller.cache
    @cache.perform_caching = false
    @cache.clear
  end
    
  def test_initialization
    assert_equal File.join(File.expand_path(RAILS_ROOT), 'vendor', 'extensions', '000_vhost'), VhostExtension.root
    assert_equal 'Vhost', VhostExtension.extension_name
  end  
  
  def test_show_page_differentiates_between_sites
    get :show_page, :url => ''
    assert_response :success
    assert_equal 'This is the body portion of the Ruby home page.', @response.body
    
    @controller = SiteController.new
    @request.host = sites(:two).hostname
    get :show_page, :url => ''
    assert_response :success
    assert_equal 'This is the Rails home page.', @response.body
  end
  
end
