gem "sinatra", "1.3.6"
require "sinatra"
require 'open-uri'
require 'json'
require 'pry'
class Movie
  attr_accessor :imdbid, :title, :plot, :actor, :director, :result, :results
  def initialize(imdb)
    file = open("http://www.omdbapi.com/?i=#{URI.escape(imdb)}&tomatoes=true")
    @result = JSON.load(file.read)
    file = open("http://www.omdbapi.com/?s=#{URI.escape(imdb)}")
    @results = JSON.load(file.read)["Search"] || []
    @title = @result['Title']
    @plot = @result['Plot']
    @imdbid = imdb 
    @actor = @result['Actors']
    @director = @result['Director']
  end
end
  before do
    @app_name = "Movies App"
    @page_title = @app_name
  end
  get '/' do
    @page_title += ": Home"
    erb :home
  end

  get '/search' do
    @query = params[:q]
    @page_title += ": Search Results for #{@query}"
    @button = params[:button]
    movie = Movie.new(@query)
    @result = movie.results
    if @result.size == 1 || (@result.size > 1 && @button == "lucky")
      redirect "/movies?id=#{@result.first["imdbID"]}"
    else
      binding.pry
      erb :serp
    end
  end

  get '/movies' do
    @id = params[:id]
    @query = params[:q]
    movie = Movie.new(@id)
    @result = movie.result
    @title = movie.title
    @plot = movie.plot
    @actors = movie.actor.split(', ')
    @directors = movie.director.split(', ')
    # @result.reject!{|m| m["Title"] == @result["Title"]}
    @page_title += ": #{@title}"
    erb :movie_details
  end
