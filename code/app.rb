require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
require_relative './model.rb'
enable :sessions



def set_error(error)
    slim(:error, locals:{message:error})
    time = Time.now
end

get("/") do
    slim(:index)
end

post("/newuser") do
    username = params[:username]
    password = params[:password]
    password_match = params[:password_match]
    db = connect_db("db/database.db")
    if test_new_username(username) == true
        if test_new_password(username, password) == true
            userid = get_userid(username)
            redirect("/newuser")
        elsif false
            set_error("Different passwords!")
        else
            set_error("Something went wrong :(")
        end
    elsif false
        set_error("That username is taken!")
    else
        set_error("Something went wrong :(")
    end
end

get("/newuser") do
    slim(:reviews, locals:{username:username, currentuserid:userid})
end

post("/reviews") do
    username = params[:username]
    password = params[:password]
    db = connect_db("db/database.db")
    if test_username(username) == true
        if test_password(username, password) == true
            session[:username] = username
            session[:currentuserid] = user_check
            redirect("/reviews")
        elsif false
            set_error("Wrong password!")
        else
            set_error("Something went wrong")
        end
    elsif false
        set_error("User does not exist")
    else
        set_error("Something went wrong")
    end
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
    slim(:reviews, locals:{:data, :title, :genre, :user, :content, :username, :currentuserid})
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



get("/users") do
    usernames = db.execute("SELECT * FROM users")
    userids = db.execute
    slim(:users, locals:{usernames:usernames})
end

get("/deleteuser") do
    #db.execute("REMOVE * FROM (users, reviews) WHERE userid = ?")
end
