require File.dirname(__FILE__) + '/test_helper'

class SqlConditionTest < Test::Unit::TestCase
  def setup
    attributes = { :name => 'Maiha' }
    @condition = SqlCondition.new(attributes)
  end

  def test_immutable_attributes
    assert_equal "Maiha", @condition.attributes[:name]
    attributes = { :name => 'Saki' }
    assert_equal "Maiha", @condition.attributes[:name]
  end

  def test_add_attribute
    @condition[:group] = 'Berryz'
    assert_equal({'name'=>"Maiha", 'group'=>'Berryz'}, @condition.attributes)
  end

  def test_overwrite_attribute
    @condition[:name] = 'Saki'
    assert_equal({'name'=>"Saki"}, @condition.attributes)
  end

  def test_generate_with_one_attribute
    assert_equal(["( name = ? )", "Maiha"], @condition.generate)
  end

  def test_generate_with_one_condition
    @condition = SqlCondition.new
    @condition.add("name = 'Maiha'")
    assert_equal ["( name = 'Maiha' )"], @condition.generate
  end

  def test_generate_with_one_attribute_and_one_condition
    @condition.add("group = 'Berryz'")
    assert_equal "( group = 'Berryz' ) AND ( name = 'Maiha' )", sanitize_sql(@condition.generate)
  end

  def test_generate_same_sqls_in_attributed_and_conditioned_ways
    attributed  = @condition
    conditioned = SqlCondition.new

    conditioned.add("name = 'Maiha'")
    assert_equal sanitize_sql(attributed.generate), sanitize_sql(conditioned.generate)
  end

  def test_generate_with_one_and_two_place_folders
    @condition.add("group = ?", 'Berryz')
    @condition.add("age BETWEEN ? AND ?", 12, 14)
    expected_sql = "( group = 'Berryz' ) AND ( age BETWEEN 12 AND 14 ) AND ( name = 'Maiha' )"
    assert_equal expected_sql, sanitize_sql(@condition.generate)
  end

  def test_generate_with_complex_constrains
    @condition.add("group = ?", 'Berryz')
    @condition.add("state IN (?)", [1,2])
    @condition[:graduate] = 1
    expected_sql = "( group = 'Berryz' ) AND ( state IN (1,2) ) AND ( graduate = 1 ) AND ( name = 'Maiha' )"
    assert_equal expected_sql, sanitize_sql(@condition.generate)
  end

  def test_generate_from_sql_condition
    @condition.add("group = ?", 'Berryz')
    cond = SqlCondition.new(@condition)
    assert_equal({"name"=>'Maiha'}, cond.attributes)
    assert_equal([SqlCondition::Constrain.new("group = ?", ['Berryz'])], cond.constrains)
  end

private
  def sanitize_sql (sql)
    ActiveRecord::Base.instance_eval do 
      sanitize_sql(sql)
    end
  end

end

