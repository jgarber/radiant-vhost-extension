require File.dirname(__FILE__) + '/../test_helper'

class SiteTest < Test::Unit::TestCase
  fixtures :sites, :pages, :users, :sites_users

  def test_overridden_validation_scope
    s = Site.create(:hostname => 'test3.host')
    assert_valid Page.create(:title => "Site 3 home", :slug => '/', :breadcrumb => 'Home', :site_id => s.id)
  end
  
  def test_site_has_many_users
    assert_equal users(:existing), sites(:one).users.first
  end
  
  def test_allow_access_for_allowed_user
    assert sites(:one).allow_access_for(users(:existing))
  end
  
  def test_allow_access_for_disallowed_user
    assert !sites(:one).allow_access_for(users(:another))
  end
  
  def test_allow_access_for_administrator
    assert sites(:one).allow_access_for(users(:admin))
  end
end