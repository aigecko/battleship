#!/usr/bin/ruby
$:.unshift File.expand_path("../../lib", __FILE__)
require "battleship/game"
require "battleship/console_renderer"
require "battleship/util"
require "stringio"
require "digest/sha1"
require "forwardable"
require "drb"

DELAY = 0
PORT = ARGV[3] ? ARGV[3].to_i : 4432

class PlayerClient
  extend Forwardable

  def initialize(secret, object)
    @secret = secret
    @object = object
  end

  def method_missing(m, *args)
    args.unshift(@secret)
    @object.__send__(m, *args)
  end

  def kill
    @object.stop(@secret)
  end
end

begin
  DRb.start_service

  player_server = File.expand_path("../player_server.rb", __FILE__)

  players = []

  2.times.each do |i|
    path = ARGV[i]
    port = PORT + i
    secret = Digest::SHA1.hexdigest("#{Time.now}#{rand}#{i}")
    system %{ruby #{player_server} "#{path}" #{port} #{secret} &}
    Battleship::Util.wait_for_socket('0.0.0.0', port)
    players << PlayerClient.new(secret, DRbObject.new(nil, "druby://0.0.0.0:#{port}"))
  end

  winners = []

  3.times do |i|
    stderr = ""
    $stderr = StringIO.new(stderr)

    game = Battleship::Game.new(10, [2, 3, 3, 4, 5], *players)
    renderer = Battleship::DeluxeConsoleRenderer.new
    ARGV[2] or $stdout << renderer.render(game)
    ARGV[2] or $stdout << stderr

    until game.winner
      t0 = Time.now
      game.tick
      time_taken = Time.now - t0
      ARGV[2] or $stdout << renderer.render(game)
      #$stdout << stderr
      #sleep [DELAY - time_taken, 0].max
    end

    ARGV[2] or puts "#{game.winner.name}"

    winners << game.winner.name
     
    #p game.round

    break if i == 1 && winners[0] == winners[1]

    players.reverse!
  end

  ARGV[2] or winners.each_with_index do |name, i|
    puts "Round #{i+1}. #{name}"
  end
  ARGV[2] and puts winners.last

  players.each &:kill
rescue Exception => e
  $stderr = STDERR
  raise e
ensure
  players.each &:kill
end
