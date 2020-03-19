require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
require_relative './model.rb'
enable :sessions

def connect_db(route)
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    return db
end

def set_error(error)
    slim(:error, locals:{message:error})
end

get("/") do
    slim(:index)
end

post("/reviews") do
    username = params[:username]
    password = params[:password]
    #password_digest = BCrypt::Password.create(password)
    db = connect_db("db/database.db")
    user_check = db.execute("SELECT userid FROM users WHERE username = ?", username)
    password_check = db.execute("SELECT password_digest FROM users WHERE username = ?", username)
    if user_check != nil
        p password
        p password_check[2]
        if password_check.first["password_digest"] == password #password_digest
            content = db.execute("SELECT content FROM reviews WHERE userid = ?", user_check.first["userid"])
            slim(:reviews, locals:{userid:user_check, content:content})
        else
            set_error("Wrong password!")
        end
    else
        set_error("User does not exist")
    end
end


post("/new") do
    db = connect_db("db/database.db")
    title = params[:title]
    title_check = db.execute("SELECT * FROM titles WHERE title = ?", title)
    if title_check.scan(/#{title}/).empty?
        db.execute("INSERT INTO titles title = ?", title)
    end
    genre = params[:genre]
    #genre_check = db.execute("SELECT genre FROM titles")
    #if genre_check.scan(/#{genre}/).empty?
    #    db.execute("INSERT INTO genres genre = ?", genre)
    #end
    review = params[:review]
    db.execute("INSERT INTO reviews (content) VALUES (?)", review)
    redirect("/reviews")
end

get("/reviews") do
    slim(:reviews)
end