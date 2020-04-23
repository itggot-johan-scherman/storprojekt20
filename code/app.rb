require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
require_relative './model.rb'
enable :sessions



def set_error(error)
    slim(:error, locals:{message:error})
end

get("/") do
    slim(:index)
end

post("/newuser") do
    username = params[:username]
    password = params[:password]
    password_match = params[:password_match]
    password_digest = BCrypt::Password.create(password)
    db = connect_db("db/database.db")
    user_check = get_userid(username)
    if user_check == nil
        if password_match == password
            add_user(username, password_digest)
            userid = get_userid(username)
            slim(:reviews, locals:{username:username, currentuserid:userid})
        else
            set_error("That username is taken!")
        end
    else
        set_error("That username is taken!")
    end
end

post("/reviews") do
    username = params[:username]
    password = params[:password]
    db = connect_db("db/database.db")
    user_check = get_userid(username)
    create_test(username, password)
    if user_check != nil
        if digest_test == digest_temp
            session[:username] = username
            slim(:reviews, locals:{username:username, currentuserid:user_check})
        else
            set_error("Wrong password!")
        end
    else
        set_error("User does not exist")
    end
end


post("/newreview") do
    db = connect_db("db/database.db")
    title = params[:title]
    genre = params[:genre]
    username = session[:username]
    genre_check = get_genres()
    genre_matches = Array.new
    genre_check.each do |element|
        genre_matches << /#{genre}/.match(element["genre"])
    end
    if !genre_matches.any?
        add_genre(genre)
    end
    genreid = get_genreid(genre)
    title_check = get_titles()
    title_matches = Array.new
    title_check.each do |element|
        title_matches << /#{title}/.match(element["title"])
    end
    if !title_matches.any?
        add_title(title, genreid)
    end
    titleid = get_titleid(title)
    review = params[:review]
    userid = get_userid(username)
    add_review(review, userid, titleid, genreid)
    redirect("/reviews")
end

get("/reviews") do
    db = connect_db("db/database.db")
    reviews = db.execute("SELECT reviewid FROM reviews")
    reviews.each do |element|
        :data = db.execute("SELECT * FROM reviews WHERE reviewid = ?", element)
        :title = db.execute("SELECT title FROM titles WHERE titleid = ?", :data[2][0])
        :genre = db.execute("SELECT genre FROM genres WHERE genreid = ?", :data[4][0])
        :user = db.execute("SELECT user FROM users WHERE userid = ?", :data[3][0])
        :content = :data[1][0]
    end
    slim(:reviews)
end

get("/users") do
    usernames = db.execute("SELECT * FROM users")
    userids = db.execute
    slim(:users, locals:{usernames:usernames})
end

get("/deleteuser") do
    #db.execute("REMOVE * FROM (users, reviews) WHERE userid = ?")
end
