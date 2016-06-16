#!/usr/bin/ruby
=begin
class P
  attr_reader :pair
  def +(other)
    @pair[0]+=other.pair[0]
    @pair[1]+=other.pair[1]
    @pair
  end
  def -(other)
    @pair[0]-=other.a
    @pair[1]-=other.b
    @pair
  end
  def initialize(a,b)
    @pair=[a,b]
  end
  def to_a
    @pair
  end
  def op
    :P
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
  def flatten
    [self]
  end
  def swap(p)
    @pair[0],p.pair[0]=p.a,@pair[0]
    @pair[1],p.pair[1]=p.b,@pair[1]
  end
  def marshal_dump
    @pair
  end
  def marshal_load(pair)
    @pair=pair
  end
end
=end
class S
  @@output={
    :P=>->(a,b){"S.new(:P,#{a},#{b})"},
    :A=>->(a){"(p+#{a.inspect})"},
    :S=>->(a){"(p-#{a.inspect})"},
    :H=>->(b,c){"((isHit.(p))?#{b.inspect}:#{c.inspect})"},
    :M=>->(b,c){"((isMiss.(p))?#{b.inspect}:#{c.inspect})"},
    :U=>->(c){"((isUnk.(p))?p:#{c.inspect})"},
    :R=>->(a,*l){a.inspect},
    :D=>->(){"S.new(:P,rand(10),rand(10))"}
  }
  @@arg={
    A: 1,S: 1,
    H: 2,M: 2,U: 1,
    R: 1,D: 0
  }
  def self.init(node,depth)
    depth==0 and return [S.new(:D),S.new(:P,rand(10),rand(10))].shuffle.first
    op=@@arg.keys.shuffle.first
    node.op=op
    @@arg[op].times{
      node<<init(S.new(:R),depth-1)
    }
    return node
  end
  attr_accessor :op,:list
  def <<(other)
    @list<<other
  end
  def initialize(op,*arg)
    @op=op
    @list=arg
  end
  def +(other)    
    S.new(:P,@list[0]+other.a, @list[1]+other.b)
  end
  def -(other)
    S.new(:P,@list[0]-other.a, @list[1]-other.b)
  end

  def a
    return @list[0]
  end
  def b
    return @list[1]
  end
  def to_a
    [a,b]
  end
  def swap(s)
    @op,s.op=s.op,@op
    @list,s.list=s.list,@list
  end
  def eval
    @@proc[@op].call(*@list)
  end
  def inspect
    @@output[@op].(*@list)
  end
  def flatten
    arr=[self]
    @op!=:P and @list.each{|s|
      arr+=s.flatten
    }
    return arr
  end
  def self.ships(map,used,list)
    list.empty?  and return
    len=list.pop
    over=false
    while(!over)
      reset=false
      dir=rand(2)
      x=rand(10)
      y=rand(10)
      if dir==1
        dir=:across
        len.times{|n|
          if used.include?([x+n,y])||x+n>9
            reset=true
            break
          end
        }
        reset and next
        map<<[x,y,len,dir]
        3.times{|n|
          used<<[x-1,y+1-n]
          used<<[x+1,y+1-n]
        }
        len.times{|n|
          used<<[x+n,y]
          used<<[x+n,y-1]
          used<<[x+n,y+1]
        }
        over=true
      else
        dir=:down
        len.times{|n|
          if used.include?([x,y+n])||y+n>9
            reset=true 
            break
          end
        }
        reset and next
        map<<[x,y,len,dir]
        3.times{|n|
          used<<[x+1-n,y-1]
          used<<[x+1-n,y+1]
        }
        len.times{|n|
          used<<[x-1,y+n]
          used<<[x,y+n]
          used<<[x+1,y+n]
        }
        over=true
      end
      ships(map,used,list)
    end
  end
  def write(file,n)
    file.puts "require_relative '../MHPlayer/expression'"
    file.puts "class MH#{n+1}Player"
    file.puts "  def name; '#{n+1}.rb' ;end"
    file.puts "  def new_game"  

    file.puts "    @p=S.new(:P,rand(10),rand(10))"
    S.ships(map=[],[],[2,3,4,4,5])
    file.puts map.inspect
  
    file.puts "  end"
    file.puts "  def take_turn(state,ships_remaining)"
    file.puts "    isHit=->(p){state[p.a][p.b]==:hit}"
    file.puts "    isMiss=->(p){state[p.a][p.b]==:miss}"
    file.puts "    isUnk=->(p){state[p.a][p.b]==:known}"
    file.puts "    p=@p"
    file.print "    p="
    file.puts self.inspect
    file.puts "     x=(!p.a.between?(0,9))?(9-p.a%10):p.a"
    file.puts "     y=(!p.b.between?(0,9))?(9-p.b%10):p.b"
    file.puts "     (@p=S.new(:P,x,y)).to_a"
    file.puts "  end"
    file.puts "end"
    file.puts "__END__"
    file.print Base64.encode64(Marshal.dump(self))
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
