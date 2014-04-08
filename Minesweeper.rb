require './WSMLogger'

class Tile
  NEIGHBORS_SPOTS = [
    [-1, -1], [1, -1], [-1, 1], [1, 1],
    [0, -1], [-1, 0], [0, 1], [1, 0]
  ]

  attr_accessor :bomb, :bombed, :revealed, :flagged, :board, :pos

  def initialize(board, pos)
    @board = board
    @pos = pos
  end

  def is_bomb?
    @bomb
  end

  def bombed?
    @bombed ||= false
  end

  def flagged?
    @flagged ||= false
  end

  def revealed?
    @revealed ||= false
  end

  def reveal(visited = [])
    self.revealed = true
    self.bombed = self.bomb

    if !bombed?
      neighbors_to_visit = neighbors.select do |neighbor|
        neighbor = self.board[neighbor]
        !neighbor.is_bomb? || !neighbor.flagged?
      end
    end

    if neighbor_bomb_count == 0
      visited << self.pos
      # p neighbors_to_visit - visited
      neighbors_to_visit = neighbors_to_visit - visited
      neighbors_to_visit.each do |neighbor|
        self.board[neighbor].reveal(visited)
      end
    end
  end


  def flag
    self.flagged = !self.flagged
  end

  def neighbors
    possible_neighbors = NEIGHBORS_SPOTS.map do |neighbor|
      [pos.first + neighbor.first, pos.last + neighbor.last]
    end

    possible_neighbors.select do |neighbor|
      neighbor[0].between?(0, self.board.size - 1) &&
      neighbor[1].between?(0, self.board.size - 1)
    end
  end

  def neighbor_bomb_count
    neighbors.inject(0) do |acc, pos|
      self.board[pos].is_bomb? ? acc + 1 : acc
    end
  end

  def to_s
    if flagged?
      "!".brown
    elsif revealed?
      bomb_count = neighbor_bomb_count #GOING TO GET CRAZY UP IN HERE
      # "Bomb count: #{bomb_count}"
      return bomb_count == 0 ? "_" : bomb_count.to_s
    else
      "$"
    end
  end

end

class Board
  attr_accessor :board_array

  def initialize(size = 9)
    self.board_array = Array.new(size) { Array.new(size) }
    init_board
  end

  def size
    self.board_array.size
  end

  def [](pos)
    # "In Board: #{pos}"
    self.board_array[pos[0]][pos[1]]
  end

  def init_board
    self.board_array.each_index do |row|
      bomb_col = (0..self.size).to_a.sample
      self.board_array.each_index do |col|
        new_tile = Tile.new(self, [row, col])
        new_tile.bomb = (col == bomb_col)
        self.board_array[row][col] = new_tile
      end
    end
  end

  def won?
    self.board_array.flatten.each do |tile|
      return false if tile.is_bomb? && !tile.flagged?
    end

    true
  end

  def lost?
    self.board_array.flatten.each do |tile|
      return true if tile.revealed? && tile.bombed?
    end

    false
  end

  def game_over?
    won? || lost?
  end

end

class Game
  attr_accessor :board

  def initialize(board_size = 9)
    self.board = Board.new(board_size)
  end

  def play
    until self.board.game_over?
      render

      command = get_move
      if command[0] == ?r
        self.board[command[1]].reveal
      elsif command[0] == ?f
        self.board[command[1]].flag
      end
    end

    puts self.board.won? ? "U.S.A! U.S.A!" : "The Soviets Win"
  end

  def render
    #Step 1: Clear Buffer
    system('clear')
    self.board.board_array.each {|row| puts row.to_s}
  end

  def get_move
    #Step 2: Get Continuous input
    puts "Hey, what's your deal?"
    valid_input = false
    until valid_input
      input = gets.chomp.to_s.split(",")
      valid_input = input.count.between?(2,3)
    end

    if input.count == 2
      return [?r] << input.map(&:to_i)
    elsif input[0].downcase == ?f
      return [?f] << input[1..2].map(&:to_i)
    end
  end

  # def get_jeff
  #   key = get_input
  #   if key == up
  #       cursor_loc_y -= 1
  # end
end

# new_board = Board.new
# new_board.board_array.each {|row| puts row.to_s}
# new_board[[0,0]].reveal
# new_board.board_array.each {|row| puts row.to_s}

Game.new(20).play