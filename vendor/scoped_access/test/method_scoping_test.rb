require File.dirname(__FILE__) + '/test_helper'

class MethodScopingTest < Test::Unit::TestCase
  def test_no_conditions
    assert_equal({ :find=>{}, :create=>{} }, MethodScoping.new(nil).method_scoping)
    assert_equal({ :find=>{}, :create=>{} }, MethodScoping.new({}).method_scoping)
  end

  def test_create_method_scoping
    method_scoping = MethodScoping.new(:name => "Maiha")
    expected = {
      :find   => { :conditions => ['( name = ? )', "Maiha"] },
      :create => { 'name' => "Maiha" },
    }
    assert_equal expected, method_scoping.method_scoping
  end

  def test_create_method_scoping_with_attributed_and_conditioned_values
    method_scoping = MethodScoping.new(:name => "Maiha")
    method_scoping.add("grade IN ?", [1,2])
    method_scoping[:group] = 'Berryz'

    expected = {
      :find   => { :conditions => ["( grade IN ? ) AND ( group = ? ) AND ( name = ? )", [1,2], "Berryz", "Maiha"] },
      :create => { 'name' => "Maiha", 'group' => "Berryz" },
    }
    assert_equal expected, method_scoping.method_scoping
  end

  def test_plus_method_with_merge
    scoping1 = MethodScoping.new(:name  => "Maiha")
    scoping2 = MethodScoping.new(:group => "Berryz")

    expected = {
      "name"  => "Maiha",
      "group" => "Berryz",
    }
    assert_equal expected, (scoping1 + scoping2).attributes
  end

  def test_plus_method_with_overwrite
    scoping1 = MethodScoping.new(:name => "Maiha", :group => "Berryz")
    scoping2 = MethodScoping.new(:name => "Saki")

    expected = {
      "name"  => "Saki",
      "group" => "Berryz",
    }
    assert_equal expected, (scoping1 + scoping2).attributes
  end
end


class ClassScopingTest < Test::Unit::TestCase
  def test_create_class_scoping
    class_scoping = ClassScoping.new(Member, :name => "Maiha")
    expected = {
      :find   => { :conditions => ['( members.name = ? )', "Maiha"] },
      :create => { 'name' => "Maiha" },
    }
    assert_equal expected, class_scoping.method_scoping
  end

  def test_create_class_scoping_from_method_scoping
    method_scoping = MethodScoping.new(:name => "Maiha")
    class_scoping  = ClassScoping.new(Member, method_scoping.attributes)

    expected = {
      :find   => { :conditions => ['( members.name = ? )', "Maiha"] },
      :create => { 'name' => "Maiha" },
    }
    assert_equal expected, class_scoping.method_scoping
  end

  def test_create_class_scoping_with_attributed_and_conditioned_values
    class_scoping = ClassScoping.new(Member, :name => "Maiha")
    class_scoping.add("grade IN ?", [1,2])
    class_scoping[:group] = 'Berryz'

    expected = {
      :find   => { :conditions => ["( members.grade IN ? ) AND ( members.group = ? ) AND ( members.name = ? )",
                                   [1,2], "Berryz", "Maiha"] },
      :create => { 'name' => "Maiha", 'group' => "Berryz" },
    }
    assert_equal expected, class_scoping.method_scoping
  end
end
