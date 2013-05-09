
require 'glr/actions'

class StackNode
  attr_accessor :state, :stacklinks
  def initialize(state, stacklinks = [])
    raise "Invalid state" unless state.is_a?(ItemSet)
    @state = state
    @stacklinks = stacklinks
  end


  def ==(sn)
    return false unless sn.is_a?(StackNode)
    return state == sn.state
  end

  def eql?(sn)
    self == sn
  end

  def actions(token)
    state.action(token)
  end

  def each_reduce(token)
    actions(token).select do |action|
      action.is_a?(Reduce)
    end
  end

  def goto(symbol)
    state.goto(symbol)
  end

  def each_link
    stacklinks.each do |link|
      yield link
    end
  end

  def unshift(link)
    stacklinks.unshift(link)
  end

  def to_s
    return "stacknode(#{state})"
  end

end

class StackLink
  attr_accessor :treenode, :backlink
  def initialize(treenode, backlink)
    @treenode = treenode
    @backlink = backlink
  end

  def ==(o)
    return false unless o.is_a?(StackLink)
    return treenode == o.treenode && backlink == o.backlink
  end

  def eql?(o)
    return self == o
  end

  def to_s
    return "stacklink(#{treenode}, #{backlink})"
  end

end
