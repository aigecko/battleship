require_relative '../MHPlayer/expression'
class MH2Player
  def name; '2.rb' ;end
  def new_game
    @p=P.new(rand(10),rand(10))
[[2, 2, 5, :down],
 [6, 6, 4, :across],
 [4, 0, 4, :down],
 [8, 0, 3, :down],
 [0, 9, 2, :across]]
  end
  def take_turn(state,ships_remaining)
    isHit=->(p){state[p.a][p.b]==:hit}
    isMiss=->(p){state[p.a][p.b]==:miss}
    isUnk=->(p){state[p.a][p.b]==:known}
    p=@p.dup
    ((isMiss.(p))?P.new(rand(10),rand(10)):((isUnk.(p))?p:P.new(3,2)))
     x=(!p.a.between?(0,9))?(10-p.a%10):p.a
     y=(!p.b.between?(0,9))?(10-p.b%10):p.b
     (@p=P.new(x,y)).to_a
  end
end
__END__
U:S[:R[U; [:M[U; [:D[ U; [:U[U:P[ii
