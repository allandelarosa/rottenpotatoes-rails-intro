class Movie < ActiveRecord::Base
    def self.ratings
        return ['G','PG','PG-13','R']
    end

    def self.with_ratings(ratings)
        return Movie.where("rating IN (?)", ratings)
    end
end
