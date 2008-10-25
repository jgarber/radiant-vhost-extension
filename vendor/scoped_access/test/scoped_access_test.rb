require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'init')

module Scopings
  ActiveMember     = MethodScoping.new(:deleted => false)
  ElementarySchool = MethodScoping.new(:grade => 1)
  JuniorHighSchool = MethodScoping.new(:grade => 2)
end

class TestController <  ActionController::Base
  attr_reader :members, :member

  def list
    @members = Member.find(:all, :order=>:id)
    render :text=>''
  end

  def show
    @member = Member.find(params[:id])
    render :text=>''
  end
end

class ScopedAccessTestCase < Test::Unit::TestCase
  fixtures :members

  def setup
    Member.instance_eval{scoped_methods.clear}
    @request  = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_dummy
  end

  private
    def test_process(controller, action = "show")
      request = ActionController::TestRequest.new
      request.action = action
      controller.process(request, ActionController::TestResponse.new)
    end      

end


class WithoutFilterTest < ScopedAccessTestCase
  class WithoutFilterController < TestController
  end

  def setup
    super
    @controller = WithoutFilterController.new
  end

  def test_filter_list
    get :list
    assert_response :success
    assert_equal %w( Saki Maiha Yurina Risako Airi ), @controller.members.map{|o| o.name}
  end

  def test_filter_show
    get :show, {'id' => "2"}
    assert_response :success
    assert_equal members(:maiha), @controller.member
  end
end

class ActiveMemberTest < ScopedAccessTestCase
  class ActiveMemberController < TestController
    around_filter ScopedAccess::Filter.new(Member, Scopings::ActiveMember)

    def nested_scoping_with_elementary_school
      Member.with_scope(Scopings::ElementarySchool) do
        @members = Member.find(:all)
      end
      render :text=>''
    end
  end

  def setup
    super
    @controller = ActiveMemberController.new
  end

  def test_filter_list
    get :list
    assert_response :success
    expected = %w( saki yurina risako airi ).collect{|name| members(name)}
    assert_equal expected, @controller.members
  end

  def test_filter_show
    assert_raises(ActiveRecord::RecordNotFound) {
      get :show, {'id' => "2"}
    }
  end

  def test_filter_nested_scoping
    get :nested_scoping_with_elementary_school
    assert_response :success
    assert_equal [members(:yurina), members(:risako)], @controller.members
  end
end


class DoubleAroundWithMergedScopedFilterTest < ScopedAccessTestCase
  class DoubleAroundWithMergedScopedFilterController < TestController
    scoped_access Member, Scopings::ActiveMember
    scoped_access Member, Scopings::JuniorHighSchool

    def list_with_exclusive_scope
      Member.with_exclusive_scope(Scopings::ElementarySchool) do
        @members = Member.find(:all)
      end
      render :text=>''
    end
  end

  def setup
    super
    @controller = DoubleAroundWithMergedScopedFilterController.new
  end

  def test_filter_list
    get :list
    assert_response :success
    assert_equal [members(:saki), members(:airi)], @controller.members
  end

  def test_filter_show_active_member
    get :show, {'id' => "1"}
    assert_response :success
    assert_equal members(:saki), @controller.member
  end

  def test_filter_show_deleted_member
    assert_raises(ActiveRecord::RecordNotFound) {    
      get :show, {'id' => "2"}
    }
  end

  def test_list_with_exclusive_scope
    get :list_with_exclusive_scope
    assert_response :success
    assert_equal [members(:yurina), members(:risako)], @controller.members
  end
end


class InheritedDoubleAroundFilterTest < ScopedAccessTestCase
  class ParentAroundFilterController < TestController
    scoped_access Member, Scopings::ActiveMember
  end

  class InheritedDoubleAroundFilterController < ParentAroundFilterController
    scoped_access Member, Scopings::JuniorHighSchool

    def list_with_conflicted_condition
      Member.with_scope(Scopings::ElementarySchool) do
        @members = Member.find(:all)
      end
      render :text=>''
    end
  end

  def setup
    super
    @controller = InheritedDoubleAroundFilterController.new
  end

  def test_filter_list
    get :list
    assert_response :success
    assert_equal [members(:saki), members(:airi)], @controller.members
  end

  def test_filter_show
    assert_raises(ActiveRecord::RecordNotFound) {
      get :show, {'id' => "2"}
    }
  end

  def test_filter_list_with_conflicted_condition
    get :list_with_conflicted_condition
    assert_response :success
    assert_equal [], @controller.members
  end
end


class ConditionalAroundFilterTest < ScopedAccessTestCase
  class ConditionalParentAroundFilterController < TestController
    scoped_access Member, Scopings::ActiveMember, :except=>:all
    scoped_access Member, Scopings::JuniorHighSchool
  end

  class InheritedDoubleConditionalAroundFilterController < ConditionalParentAroundFilterController
    scoped_access Member, Scopings::ElementarySchool, :only=>:list_with_conflicted_condition

    def list_with_conflicted_condition
      @members = Member.find(:all)
      render :text=>''
    end

    def list
      @members = Member.find(:all)
      render :text=>''
    end

    def all
      @members = Member.find(:all)
      render :text=>''
    end
  end

  def setup
    super
    @controller = InheritedDoubleConditionalAroundFilterController.new
  end

  def test_filter_list_out_of_only_condition
    expected = Member.with_exclusive_scope(Scopings::ActiveMember+Scopings::JuniorHighSchool){Member.find(:all)}
    get :list
    assert_response :success
    assert_equal expected, @controller.members
  end

  def test_filter_show
    assert_raises(ActiveRecord::RecordNotFound) {
      get :show, {'id' => "2"}
    }
  end

  def test_filter_list_with_conflicted_condition
    get :list_with_conflicted_condition
    assert_response :success
    assert_equal [], @controller.members
  end

  def test_filter_except_condition
    expected = Member.with_exclusive_scope(Scopings::JuniorHighSchool){Member.find(:all)}
    get :all
    assert_response :success
    assert_equal expected, @controller.members
  end
end

