
require 'rules2'
require 'test/unit'

class TestRules < Test::Unit::TestCase

  def setup
    @rule = Rule.new(:add, :Exp, [:Exp, :Add, :Exp])
    @rule2 = Rule.new(:add, :Exp, [:Exp, :Add, :Exp])
    @layout = Rule.make(:add, :Exp, [:Exp, :Add, :Exp], :LAYOUT)
  end

  def test_enable_enables
    @rule.enable(:module)
    assert(@rule.enabled?(:module))
  end

  def test_disable_disables
    @rule.enable(:module)
    @rule.disable(:module)
    assert !@rule.enabled?(:module)
  end

  def test_unused
    assert @rule.unused?
  end

  def test_length_no_layout
    assert_equal(@rule.length, 3)
  end

  def test_length_with_layout
    assert_equal(@layout.length, 5)
  end

  def test_has_layout_without_layout
    assert !@rule.has_layout?
  end

  def test_has_layout_with_layout
    assert @layout.has_layout?
  end

  def test_layout_symbol
    assert_equal(@layout.elements[1], :LAYOUT)
    assert_equal(@layout.elements[3], :LAYOUT)
  end

  def test_result_symbol
    assert_equal(@rule.result, :Exp)
  end

  def test_result_symbol_layout
    assert_equal(@layout.result, :Exp)
  end

  def test_label
    assert_equal(@rule.label, :add)
  end

  def test_label_layout
    assert_equal(@layout.label, :add)
  end

  def test_equality_equal
    assert_equal(@rule, @rule2)
  end

  def test_equality_non_equal
    assert_not_equal(@rule, @layout)
  end

end
