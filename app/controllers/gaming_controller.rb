require 'open-uri'
require 'json'

class GamingController < ApplicationController
  def game
    @grid = generate_grid
    @start_time = Time.now
  end

  def score
    finish_time = Time.now
    @my_word = params[:my_word]
    @grid = params[:grid].split(//)
    start_time = params[:start_time].to_time
    @result = run_game(@my_word, @grid, start_time, finish_time)
  end

private

  def generate_grid
    # TODO: generate random grid of letters
    grid = []
    (0..7).each do |i|
      grid[i] = ("A".."Z").to_a.sample(1)
    end
    return grid
  end

  def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result
  attempt_formatted = attempt.upcase.split(//)
  grid_mod = Hash.new(0)
  attempt_hash = Hash.new(0)
  result = {
    time: (end_time - start_time).round(3)
  }
  if result[:time] > 30
    result[:score] = 0
    result[:translation] = nil
    result[:message] = "too slow..."
    return result
  end

  grid.each do |letter|
    if attempt_formatted.include?(letter)
      grid_mod[letter] += 1
    end
  end

  attempt_formatted.each do |letter|
    attempt_hash[letter] += 1
  end

  if grid_mod.keys.sort == attempt_hash.keys.sort
    grid_mod.each do |key, _value|
      if grid_mod[key] < attempt_hash[key]
        result[:score] = 0
        result[:translation] = nil
        result[:message] = "not in the grid"
      end
    end
  else
    result[:score] = 0
    result[:translation] = nil
    result[:message] = "not in the grid"
  end

  unless result[:score] == 0
    api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"

    open(api_url) do |f|
      api_res = JSON.parse(f.read)
      if api_res.keys[0] == "Error"
        result[:score] = 0
        result[:translation] = nil
        result[:message] = "not an english word"
      else
        result[:score] = (attempt.size * 30 - result[:time]).round
        result[:translation] = api_res["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
        result[:message] = "well done"
      end
    end
  end
  return result
end
end

