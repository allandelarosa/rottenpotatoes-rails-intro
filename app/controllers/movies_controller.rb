class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings()

    # default hash to indicate all ratings should be displayed
    default = Hash[@all_ratings.collect { |rating| [rating, 1] } ]

    # check if invalid rating selection
    # if first time visiting page, show all ratings
    if params[:ratings].nil?
      flash.keep # need this in case a message is to be displayed
      redirect_to movies_path ratings: session[:ratings] ? session[:ratings] : default, 
        sort: params[:sort]
    end

    # if sort not specified, revert to previous value
    if params[:sort].nil?
      params[:sort] = session[:sort]
    end

    # store values in session to save sorting/filtering
    session[:ratings] = params[:ratings]
    session[:sort] = params[:sort]

    # keeps track of which ratings are checked
    # need the conditional, even if redirection occurs before this
    # entire class must be valid at all times
    @selected = params[:ratings].keys unless params[:ratings].nil?
    
    # determine what movies are displayed
    @movies = case params[:sort]
    when "by_title"
      Movie.order(:title).with_ratings(@selected)
    when "by_release_date"
      Movie.order(:release_date).with_ratings(@selected)
    else
      Movie.with_ratings(@selected)
    end
    
    # determine if table header will be highlighted
    @title_class = params[:sort] == "by_title" ? :hilite : ""
    @release_date_class = params[:sort] == "by_release_date" ? :hilite : ""

    # variables for sorting links, to clean up view
    @title_path = movies_path(sort:"by_title", ratings: params[:ratings])
    @release_date_path = movies_path(sort:"by_release_date", ratings: params[:ratings])
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
