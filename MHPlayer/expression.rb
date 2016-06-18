#!/usr/bin/ruby
class S
  @@output={
    :A=>->(b){"+\nS.new(:P,*v[@dir])#{b.inspect}"},
    :L=>->(b){"+\nS.new(:P,*v[@dir=(@dir-1)%4])#{b.inspect}"},
    :T=>->(b){"+\nS.new(:P,*v[@dir=(@dir+1)%4])#{b.inspect}"},
    :Q=>->(){";"},

    :R=>->(a,*l){a.inspect}
  }
  @@arg={
    A: 1,L: 1,T: 1,
    R: 1
  }
  def self.init(node,depth)
    depth==0 and return S.new(:Q)
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
  def single_swap(s)
    swap(s)
    s.list.any? and @list.zip(s.list){|a,b| a.swap(b)}
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
          used<<[x+len,y+1-n]
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
          used<<[x+1-n,y+len]
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
    file.puts "  attr_accessor :fix"
    file.puts "  def name; '#{n+1}.rb' ;end"
    file.puts "  def new_game"  

    file.puts "    @p=S.new(:P,0,0)"
    file.puts "    @fix=0"
    file.puts "    @dir=2"
    S.ships(map=[],[],[2,3,3,4,5])
    file.puts map.inspect
  
    file.puts "  end"
    file.puts "  def take_turn(state,ships_remaining)"
    file.puts "    v=[[-1,0],[0,1],[1,0],[0,-1]]"
    file.print "   p=@p"
    file.puts self.inspect
    file.puts "    x=(!p.b.between?(0,9))?(9-p.b%10):p.b"
    file.puts "    y=(!p.a.between?(0,9))?(9-p.a%10):p.a"
    file.puts "    if(state[y][x]!=:unknown)"
    file.puts "      @fix+=1"
    file.puts "      (@p=S.new(:P,*state.map.with_index{|row,x| row.map.with_index{|s,y| [y,x,s]}}.inject(&:+).keep_if{|a| a[2]==:unknown}.sort_by!{|a| (y-a[0]).abs+(x-a[1]).abs}.first[0..1])).to_a"
    file.puts "    else"
    file.puts "      (@p=S.new(:P,x,y)).to_a"
    file.puts "    end"
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
