class MHPlayer1
  def name; 'MHPlayer1' ;end
  def new_game
[[2, 5, 5, :across],
 [5, 0, 4, :down],
 [0, 4, 4, :down],
 [9, 1, 3, :down],
 [5, 8, 2, :across]]
  end
  def take_turn(state,ships_remaining)
    isHit=->(p){state[p.a][p.b]==:hit}
    p=P.new(0,0)
    (p+=P.new(0,5))
    p.to_a
  end
end
__END__
U:S[:R[U; [;[U; [:A[U:P[i i
