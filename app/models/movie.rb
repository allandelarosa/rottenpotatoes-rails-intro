class Movie < ActiveRecord::Base
    # returns an array of ratings currently in the database
    def self.ratings
        ratings = []
        Movie.all.each do |movie|
            ratings += [movie.rating.upcase]
        end
        return ratings.uniq
    end

    def self.with_ratings(ratings)
        return self.where("upper(rating) IN (?)", ratings)
    end
end
