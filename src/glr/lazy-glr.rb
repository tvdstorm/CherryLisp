require 'thread'

class TokenBuffer

  def initialize
    @tokens = []
    @lock = Mutex.new
  end

  def add(tokens)
    @lock.synchronize do
      @tokens += tokens
    end
  end

  def feed(string)
    add(string.split(''))
  end

  def empty?
    @lock.synchronize do
      return @tokens.empty?
    end
  end

  def close
    add([:EOF])
  end

  def get
    while empty? do
      Thread.pass
    end
    @lock.synchronize do
      @tokens.shift
    end
  end

  def shift
    get
  end

end

class LazyGLR
  attr_reader :buffer

  def initialize(parser)
    @parser = parser
    @buffer = TokenBuffer.new
    @thread = Thread.new do 
      parser.parse(self)
    end
  end
  
  def shift
    while buffer.empty? do
      Thread.pass
    end
    return buffer.get
  end
  
  def result
    add([:EOF])
    return @thread.value
  end

  def feed(string)
    add(string.split(''))
  end

  private

  def add(tokens)
    buffer.add(tokens)
  end
  

end
