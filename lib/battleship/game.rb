require "battleship/board"

module Battleship
  class Game
    attr_accessor :round,:fired
    def initialize(size, expected_fleet, *players)
      @state = build_initial_state(size, expected_fleet, players)

      @turn = 0
      @round = 0
      @fired = [0, 0]

      @state.reverse.each do |player, opponent, board|
        unless board.valid?
          @winner ||= player
        end
      end
    end

    attr_reader :winner

    def tick
      player, opponent, board = @state[@turn]
      @fired[@turn]+=1
      @turn = -(@turn - 1)

      move = dup_if_possible(player.take_turn(board.report, board.ships_remaining))
      result = board.try(move)

      board.try([move[0]+1,move[1]+1])
      board.try([move[0]+1,move[1]-1])
      board.try([move[0]-1,move[1]+1])
      board.try([move[0]-1,move[1]-1])

      if result == :invalid
        @winner = opponent
      elsif board.sunk?
        @winner = player
      end
      
      @round+=1

      result
    end

    def names
      @state.map{ |player, _, __| player.name }
    end

    def report
      @state.reverse.map{ |_, __, board| board.report }
    end

    def ships_remaining
      @state.reverse.map{ |_, __, board| board.ships_remaining }
    end

    def fix_counts
      @state.map{ |player,_,__| player.fix}
    end

  private
    def dup_if_possible(v)
      v.dup
    rescue TypeError
      v
    end

    def build_initial_state(size, expected_fleet, players)
      boards = players.map{ |player|
        positions = player.new_game
        Board.new(size, expected_fleet, positions)
      }
      players.zip(players.reverse, boards.reverse)
    end
  end
end
