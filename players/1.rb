class MH1Player
  def name; 'MH1Player' ;end
  def new_game
[[7, 1, 5, :down],
 [0, 3, 4, :down],
 [2, 7, 4, :across],
 [8, 7, 3, :down],
 [9, 1, 2, :down]]
  end
  def take_turn(state,ships_remaining)
    isHit=->(p){state[p.a][p.b]==:hit}
    p=@p
    (p+=(p+=P.new(9,8)))
    (@p=p).to_a
  end
end
__END__
U:S[:A[U; [;[U; [:R[U:P[ii
