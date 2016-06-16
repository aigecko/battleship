require_relative '../MHPlayer/expression'
class MH3Player
  def name; '3.rb' ;end
  def new_game
    @p=P.new(rand(10),rand(10))
[[0, 0, 5, :across],
 [1, 3, 4, :down],
 [4, 4, 4, :across],
 [2, 7, 3, :down],
 [5, 7, 2, :down]]
  end
  def take_turn(state,ships_remaining)
    isHit=->(p){state[p.a][p.b]==:hit}
    isMiss=->(p){state[p.a][p.b]==:miss}
    isUnk=->(p){state[p.a][p.b]==:known}
    p=@p.dup
    ((isMiss.(p))?(p-=((isHit.(p))?P.new(1,8):P.new(6,7))):(p+=((isMiss.(p))?P.new(rand(10),rand(10)):P.new(6,5))))
     x=(!p.a.between?(0,9))?(10-p.a%10):p.a
     y=(!p.b.between?(0,9))?(10-p.b%10):p.b
     (@p=P.new(x,y)).to_a
  end
end
__END__
U:S[:M[U; [; [U; [:H[U:P[iiU;[iiU; [:A[U; [;[U; [:D[ U;[ii
