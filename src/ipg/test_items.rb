

require 'test/unit'
require 'items2'
require 'rules2'

class TestItems < Test::Unit::TestCase
  def setup
    @rule = Rule.new(:add, :Exp, [:Exp, :Add, :Exp])
    @rule2 = Rule.new(:minus, :Exp, [:Exp, :Minus, :Exp])
    @item = Item.new(@rule, 0)
    @item_eq = Item.new(@rule, 0)
    @item_neq = Item.new(@rule2, 0)
  end

  def test_result_equals_rule_result
    assert_equal(@item.result, @rule.result)
  end
 
  def test_enabled_equals_rule_enabled
    @rule.enable(:module)
    assert @item.enabled?(:module)
  end

  def test_disabled_equals_rule_disabled
    assert !@item.enabled?(:module)
  end

  def test_dot_initialized
    assert_equal(@item.dot, 0)
  end

  def test_move_dot
    assert_equal(@item.move_dot.dot, 1)
  end

  def test_equality_equal
    assert_equal(@item, @item_eq)
  end

  def test_equality_non_equal
    assert_not_equal(@item, @item_neq)
  end

  def test_next_symbol_initial
    assert_equal(@item.next_symbol, :Exp)
  end

  def test_next_symbol_moved
    assert_equal(@item.move_dot.next_symbol, :Add)
  end

end
