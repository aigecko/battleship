require_relative '../MHPlayer/expression'
class MH1Player
  def name; '1.rb' ;end
  def new_game
    @p=P.new(rand(10),rand(10))
[[0, 7, 5, :across],
 [5, 8, 4, :across],
 [3, 0, 4, :down],
 [9, 4, 3, :down],
 [1, 3, 2, :down]]
  end
  def take_turn(state,ships_remaining)
    isHit=->(p){state[p.a][p.b]==:hit}
    isMiss=->(p){state[p.a][p.b]==:miss}
    isUnk=->(p){state[p.a][p.b]==:known}
    p=@p.dup
    P.new(rand(10),rand(10))
     x=(!p.a.between?(0,9))?(10-p.a%10):p.a
     y=(!p.b.between?(0,9))?(10-p.b%10):p.b
     (@p=P.new(x,y)).to_a
  end
end
__END__
U:S[:D[ 
