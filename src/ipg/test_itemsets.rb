
require 'test/unit'
require 'itemset'
require 'items2'
require 'rules2'

class TestItemSets << Test::Unit::TestCase
  def setup
    @rule = Rule.new(:add, :Exp, [:Exp, :Add, :Exp])
    @rule2 = Rule.new(:minus, :Exp, [:Exp, :Minus, :Exp])
    @item = Item.new(@rule, 0)
    @item_eq = Item.new(@rule, 0)
    @item_neq = Item.new(@rule2, 0)
  end

end
