require_relative '../MHPlayer/expression'
class MH4Player
  def name; '4.rb' ;end
  def new_game
    @p=P.new(rand(10),rand(10))
[[0, 6, 5, :across],
 [6, 5, 4, :down],
 [6, 9, 4, :across],
 [2, 0, 3, :across],
 [1, 8, 2, :down]]
  end
  def take_turn(state,ships_remaining)
    isHit=->(p){state[p.a][p.b]==:hit}
    isMiss=->(p){state[p.a][p.b]==:miss}
    isUnk=->(p){state[p.a][p.b]==:known}
    p=@p.dup
    (p+=(p-=P.new(8,1)))
     x=(!p.a.between?(0,9))?(10-p.a%10):p.a
     y=(!p.b.between?(0,9))?(10-p.b%10):p.b
     (@p=P.new(x,y)).to_a
  end
end
__END__
U:S[:A[U; [:R[U; [; [U:P[ii
