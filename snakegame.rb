require 'ruby2d'
require 'rubygems'
require 'gosu'

set background: 'navy'
set fps_cap: 20

SQUARE_SIZE = 20
GRID_WIDTH = Window.width / SQUARE_SIZE
GRID_HEIGHT = Window.height / SQUARE_SIZE
WIDTH = Window.width
HEIGHT = Window.height

class Snake
  attr_accessor :direction

  def initialize
    @positions = [[2, 0], [2, 1], [2, 2], [2 ,3]]
    @direction = 'down'
    @growing = false
  end

  def draw
    Image.new('media/snake.png', x: head[0] * SQUARE_SIZE, y: head[1] * SQUARE_SIZE)
    @positions[0 .. -2].each do |position|
      Circle.new(x: position[0] * SQUARE_SIZE + SQUARE_SIZE / 2, y: position[1] * SQUARE_SIZE + SQUARE_SIZE / 2, radius: SQUARE_SIZE / 2- 1, color: 'green')
    end
  end

  def grow
    @growing = true
  end

  def move
    if !@growing
      @positions.shift
    end

    @positions.push(next_position)
    @growing = false
  end

  def can_change_direction_to?(new_direction)
    case @direction
    when 'up' then new_direction != 'down'
    when 'down' then new_direction != 'up'
    when 'left' then new_direction != 'right'
    when 'right' then new_direction != 'left'
    end
  end

  def x
    head[0]
  end

  def y
    head[1]
  end

  def next_position
    if @direction == 'down'
      new_coords(head[0], head[1] + 1)
    elsif @direction == 'up'
      new_coords(head[0], head[1] - 1)
    elsif @direction == 'left'
      new_coords(head[0] - 1, head[1])
    elsif @direction == 'right'
      new_coords(head[0] + 1, head[1])
    end
  end

  def hit_itself?
    @positions.uniq.length != @positions.length
  end

  private

  def new_coords(x, y)
    [x % GRID_WIDTH, y % GRID_HEIGHT]
  end

  def head
    @positions.last
  end
end

class Game
  attr_accessor :apple
  def initialize
    @apple = nil
    @apple_x = rand(GRID_WIDTH)
    @apple_y = rand(GRID_HEIGHT)
    @score = 0
    @level = 1
    @finished = false
    @getscore = Gosu::Sample.new("media/ting.wav")
    @boom = nil
    @fire_x = rand(SQUARE_SIZE)
    @fire_y = rand(SQUARE_SIZE)
    @boom_x = rand(SQUARE_SIZE)
    @boom_y = rand(SQUARE_SIZE)
    @boom1_x = rand(SQUARE_SIZE)
    @boom1_y = rand(SQUARE_SIZE)
    select_apple
  end

  def select_apple
    apples = {biga: ['media/bigapple.png', 1], smalla: ['media/smallapple.png', 2] }
    @apple = apples[apples.keys.sample]
  end

  def draw
    unless @finished
      #apple 
      Image.new(@apple[0], x: @apple_x * SQUARE_SIZE, y: @apple_y * SQUARE_SIZE)
      #fire
      Image.new('media/fire.png', x: @fire_x * SQUARE_SIZE, y: @fire_y * SQUARE_SIZE)
      Image.new('media/fire.png', x: @fire_x * SQUARE_SIZE + SQUARE_SIZE / 2, y: @fire_y*SQUARE_SIZE + SQUARE_SIZE / 2)
      Image.new('media/fire.png', x: @fire_x * SQUARE_SIZE - SQUARE_SIZE / 2.5, y: @fire_y*SQUARE_SIZE - SQUARE_SIZE / 2.5)
      Image.new('media/fire.png', x: @fire_x * SQUARE_SIZE + SQUARE_SIZE / 2.5, y: @fire_y*SQUARE_SIZE - SQUARE_SIZE / 2.5)
      Image.new('media/fire.png', x: @fire_x * SQUARE_SIZE - SQUARE_SIZE / 3, y: @fire_y*SQUARE_SIZE + SQUARE_SIZE / 3)
      Image.new('media/fire.png', x: @fire_x * SQUARE_SIZE + SQUARE_SIZE / 3, y: @fire_y*SQUARE_SIZE + SQUARE_SIZE / 3)
      #boom
      Image.new('media/boom.png', x: @boom_x * SQUARE_SIZE, y: @boom_y*SQUARE_SIZE)
      Image.new('media/boom.png', x: @boom1_x * SQUARE_SIZE, y: @boom1_y*SQUARE_SIZE)
    end
    Text.new(text_message, color: 'green', x: 10, y: 10, size: 25, z: 1)
  end

  def draw_gameover
    Image.new('media/snake.png', x: 80, y: 50)
    Image.new('media/boom1.png', x: 100, y:40)
    Circle.new(x: 200, y: 50, radius: SQUARE_SIZE / 2- 1, color: 'green')
    Circle.new(x: 300, y: 60, radius: SQUARE_SIZE / 2- 1, color: 'green')
    Circle.new(x: 350, y: 70, radius: SQUARE_SIZE / 2- 1, color: 'green')
  end

  def snake_hit_apple?(x, y)
    @apple_x == x && @apple_y == y
  end

  def snake_hit_fire?(x, y)
    @fire_x == x && @fire_y == y
  end

  def snake_hit_boom?(x, y)
    @boom_x == x && @boom_y == y
  end

  def snake_hit_boom1?(x, y)
    @boom1_x == x && @boom1_y == y
  end

  def record_hit
    @score += @apple[1]
    select_apple
    @getscore.play
    #random apple
    @apple_x = rand(Window.width / SQUARE_SIZE)
    @apple_y = rand(Window.height / SQUARE_SIZE)
    #random fire
    @fire_x = rand(Window.width / SQUARE_SIZE)
    @fire_y = rand(Window.height / SQUARE_SIZE)
    #random boom
    @boom_x = rand(Window.width / SQUARE_SIZE)
    @boom_y = rand(Window.height / SQUARE_SIZE)
    #random boom1
    @boom1_x = rand(Window.width / SQUARE_SIZE)
    @boom1_y = rand(Window.height / SQUARE_SIZE)
  end

  def levelup
    if (@level == 1 and @score == 10)
      @level += 1
    end
  end

  def finish
    @finished = true
    draw_gameover
  end

  def finished?
    @finished
  end

  private

  def text_message
    if finished?
      "Game over. Your Score was #{@score}. Press 'R' to restart. "
    else
      "Score: #{@score} Level: #{@level}"
    end
  end
end

snake = Snake.new
game = Game.new


update do
  clear

  unless game.finished?
    snake.move
  end

  snake.draw
  game.draw

  if game.snake_hit_apple?(snake.x, snake.y)
    game.record_hit
    snake.grow
  end

  if game.snake_hit_fire?(snake.x, snake.y)
    game.finish
  end

  if game.snake_hit_boom?(snake.x, snake.y)
    game.finish
  end

  if game.snake_hit_boom1?(snake.x, snake.y)
    game.finish
  end

  if game.levelup
    game.levelup
  end

  if snake.hit_itself?
    game.finish
  end

end

on :key_down do |event|
  if ['up', 'down', 'left', 'right'].include?(event.key)
    if snake.can_change_direction_to?(event.key)
      snake.direction = event.key
    end
  end

  if game.finished? && event.key == 'r'
    snake = Snake.new
    game = Game.new
  end
end

show