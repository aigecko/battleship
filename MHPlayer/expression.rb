#!/usr/bin/ruby
class P
  attr_reader :pair
  def +(other)
    @pair[0]+=other.pair[0]
    @pair[1]+=other.pair[1]
    @pair
  end
  def initialize(a,b)
    @pair=[a,b]
  end
  def to_a
    @pair
  end
  def a
    return @pair[0]
  end
  def b
    return @pair[1]
  end
  def inspect
    "P.new(#{@pair[0]},#{@pair[1]})"
  end
  def marshal_dump
    @pair
  end
  def marshal_load(pair)
    @pair=pair
  end
end
class S
  @@output={
    :A=>->(a){"(p+=#{a.inspect})"},
    :H=>->(a,b,c){"((isHit.(#{a.inspect}))?#{b.inspect}:#{c.inspect})"},
    :R=>->(a,*l){a.inspect}
  }
  @@arg={
    A: 1,
    H: 3,
    R: 1
  }
  def self.init(node,depth)
    depth==0 and return P.new(rand(10),rand(10))
    op=@@arg.keys.shuffle.first
    node.op=op
    @@arg[op].times{
      node<<init(S.new(:R),depth-1)
    }
    return node
  end
  attr_accessor :op
  def <<(other)
    @list<<other
  end
  def initialize(op,*arg)
    @op=op
    @list=arg
  end
  def eval
    @@proc[@op].call(*@list)
  end
  def inspect
    @@output[@op].(*@list)
  end
  def marshal_dump
    [@op,@list]
  end
  def marshal_load(arr)
    if arr.respond_to? :map
      @op=arr[0]
      @list=arr[1].map{|s| marshal_load(s)}
    else
      arr
    end
  end
end
