require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

def connect_db(route)
    db = SQLite3::Database.new(route)
    db.results_as_hash = true
end

get("/") do
    slim(:index)
end

post("/reviews") do
    username = params[:username]
    password = params[:password]
    password_digest = BCrypt::Password.create(password)
    db = connect_db("db/database.db")
    user_check = db.execute("SELECT id FROM users WHERE username = ?", username)
    password_check = db.execute("SELECT password_digest FROM users WHERE username = ?", username)
    if user_check != nil
        if password_check == password_digest
            content = db.execute("SELECT content FROM reviews WHERE userid = ?", user_check)
            slim(:reviews, locals:{userid:user_check, content:content})
        else
            set_error("Wrong password!")
            redirect("/error")
        end
    else
        set_error("User does not exist")
        redirect("/error")
    end
end

post("/new") do
 #   db = connect_db("db/database.db")
  #  title = params[:title]
   # title_check = db.execute("SELECT title FROM titles")
    #if title_check.scan(/#{title}/).empty?
     #   db.execute("INSERT INTO titles title = ?", title)
    #end
#    genre = params[:genre]
 #   genre_check = db.execute("SELECT title FROM titles")
  #  if genre_check.scan(/#{genre}/).empty?
   #     db.execute("INSERT INTO genres genre = ?", genre)
    #end
 #   review = params[:review]
  #  db.execute("INSERT INTO reviews content = ?", review)
   # redirect("/reviews")
end