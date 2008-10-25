require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/page_controller'

# Re-raise errors caught by the controller.
class Admin::PageController; def rescue_action(e) raise e end; end

class Admin::PageControllerTest < Test::Unit::TestCase
  fixtures :users, :pages, :sites, :sites_users
  test_helper :pages, :page_parts, :caching
  
  def setup
    @controller = Admin::PageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session['user'] = users(:another)
    @request.host = sites(:two).hostname
    
    @page_title = 'Just a Test'
    
    destroy_test_page
    destroy_test_part
  end

  def test_index
    get :index
    assert_response :success
    assert_kind_of Page, assigns(:homepage)
  end
  
  def test_index__without_pages
    Page.destroy_all
    get :index
    assert_response :success
    assert_nil assigns(:homepage)
  end
  
  def test_new
    @controller.config = {
      'defaults.page.parts' => 'body, extended, summary',
      'defaults.page.status' => 'published'
    }
    
    get :new, :parent_id => '2', :page => page_params
    assert_response :success
    assert_template 'admin/page/edit'
    
    @page = assigns(:page)
    assert_kind_of Page, @page
    assert_nil @page.title
    
    @expected_parent = Page.find(2)
    assert_equal @expected_parent, @page.parent
    
    assert_equal 3, @page.parts.size
    assert_equal Status[:published], @page.status
  end
  def test_new__post_with_parts
    post(:new, :parent_id => '2', :page => page_params,
      :part => {
        '1' => part_params(:name => 'test-part-1'),
        '2' => part_params(:name => 'test-part-2')
      }
    )
    assert_redirected_to page_index_url
    
    @page = get_test_page
    assert_kind_of Page, @page
    assert_equal sites(:two).id, @page.site_id
    names = @page.parts.collect { |part| part.name }.sort
    assert_equal ['test-part-1', 'test-part-2'], names
  end
  def test_new__save_and_continue_editing
    post :new, :parent_id => '2', :page => page_params, :continue => 'Save and Continue Editing'
    @page = get_test_page
    assert_equal sites(:two).id, @page.site_id
    assert_redirected_to page_edit_url(:id => @page.id)
  end
  
  def test_edit
    get :edit, :id => '2', :page => page_params
    assert_response :success
    
    @page = assigns(:page)
    assert_kind_of Page, @page
    assert_equal 'Rails Home Page', @page.title
    assert_equal sites(:two).id, @page.site_id
  end  
  def test_edit__post
    @page = create_test_page(:site_id => sites(:two).id)
    post :edit, :id => @page.id, :page => page_params(:status_id => '1')
    assert_response :redirect
    assert_equal 1, get_test_page.status.id
  end
  def test_edit__post_with_parts
    @page = create_test_page(:no_part => true, :site_id => sites(:two).id)
    @page.parts.create(part_params(:name => 'test-part-1'))
    @page.parts.create(part_params(:name => 'test-part-2'))
    
    assert_equal 2, @page.parts.size
    
    post :edit, :id => @page.id, :page => page_params, :part => {'1' => part_params(:name => 'test-part-1', :content => 'changed')}
    assert_response :redirect
    
    @page = get_test_page 
    assert_equal 1, @page.parts.size
    assert_equal 'changed', @page.parts.first.content
  end

  def test_remove
    @page = create_test_page(:site_id => sites(:two).id)
    get :remove, :id => @page.id 
    assert_response :success
    assert_equal @page, assigns(:page)
    assert_not_nil get_test_page
  end
  def test_remove__post
    @page = create_test_page(:site_id => sites(:two).id)
    post :remove, :id => @page.id
    assert_redirected_to page_index_url
    assert_match /removed/, flash[:notice]
    assert_nil get_test_page
  end
  
  def test_access_prohibited_to_user_without_access_to_site
    @request.session['user'] = users(:existing)
    get :edit, :id => '2'
    assert_response :redirect
    assert_equal 'Access denied.', flash[:error]
  end
  
  protected
  
    def assert_rendered_nodes_where(&block)
      wanted, unwanted = Page.find(:all).partition(&block)
      wanted.each do |page|
        assert_tag :tag => 'tr', :attributes => {:id => "page-#{page.id}" }
      end
      unwanted.each do |page|
        assert_no_tag :tag => 'tr', :attributes => {:id => "page-#{page.id}" }
      end
    end
end
