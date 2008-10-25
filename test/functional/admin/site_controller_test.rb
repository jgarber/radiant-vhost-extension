require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
Admin::SiteController.class_eval { def rescue_action(e) raise e end }

class SiteControllerTest < Test::Unit::TestCase
  fixtures :users, :sites, :sites_users
  
  def setup
    @controller = Admin::SiteController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = sites(:two).hostname
  end

  [:index, :new, :edit, :remove].each do |action|
    define_method "test_#{action}_action_allowed_if_admin" do
      get action, { :id => 1 }, { 'user' => users(:admin) }
      assert_response :success, "action: #{action}"
    end

    define_method "test_#{action}_action_not_allowed_if_other" do
      get action, { :id => 1 }, { 'user' => users(:non_admin) }
      assert_redirected_to page_index_url, "action: #{action}"
      assert_match /privileges/, flash[:error], "action: #{action}"
    end
  end
  
  def test_new_creates_root_page
    post :new, {:site => {:hostname => 'test3.host'}}, { 'user' => users(:admin) }
    assert_response :redirect
    assert_not_nil Site.find_by_hostname('test3.host')
    assert_not_nil Page.find_by_slug_and_site_id('/', Site.find_by_hostname('test3.host').id)  
  end
end
