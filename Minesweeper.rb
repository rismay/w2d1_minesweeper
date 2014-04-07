require './WSMLogger'

class Tile
  NEIGHBORS_SPOTS = [[-1,-1], [1,-1], [-1,1], [1,1], [0,-1], [-1,0], [0,1], [1,0]]
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

  def reveal(visited=[])

    self.bombed = self.bomb

    unless bombed?
      self.revealed = true
      neighbors_to_visit = neighbors.select do |neighbor|
        !self.board[neighbor].is_bomb?
      end

      visited << self.pos
      p neighbors_to_visit - visited
      neighbors_to_visit = neighbors_to_visit - visited
      neighbors_to_visit.each do |neighbor|
        self.board[neighbor].reveal(visited) if neighbor_bomb_count == 0
      end
    end

  end

  def neighbors
    possible_neighbors = NEIGHBORS_SPOTS.map do |neighbor|
      [pos.first + neighbor.first, pos.last + neighbor.last]
    end

    possible_neighbors.select do |neighbor|
      neighbor[0].between?(0,self.board.size-1) && neighbor[1].between?(0,self.board.size-1)
    end
  end

  def neighbor_bomb_count
    neighbors.inject(0) do |acc, pos|
      acc += self.board[pos].is_bomb? ? 1 : 0
    end
  end

  def to_s
    return "%".red if is_bomb?

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
        new_tile.bomb = true if col == bomb_col
        self.board_array[row][col] = new_tile
      end
    end
  end

  def won?
    self.board_array.each_index do |row|
      row.each_index do |col|
        tile = self.board_array[row][col]
        return false if tile.is_bomb? && !tile.flagged?
      end
    end

    true
  end

  def lost?
    self.board_array.each_index do |row|
      row.each_index do |col|
        tile = self.board_array[row][col]
        return true if tile.reavealed? && tile.bombed?
      end
    end

    false
  end

  def game_over
    won? || lost?
  end

end

class Game
  attr_accessor :board

  def initialize(board = Board.new)

  end

  def play
    until self.board.game_over?
      get_move
    end
  end

  def get_move

  end
end

new_board = Board.new
new_board.board_array.each {|row| puts row.to_s}
new_board[[0,0]].reveal
new_board.board_array.each {|row| puts row.to_s}

Game.new.play