require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
require_relative './model.rb'
enable :sessions



def set_error(error)
    slim(:error, locals:{message:error})
    session[:time] = Time.now
end

get("/") do
    slim(:index)
end

post("/users/new") do
    if check_time(:time) == false
        set_error("DDOS")
    end
    username = params[:username]
    password = params[:password]
    password_match = params[:password_match]
    db = connect_db("db/database.db")
    if test_new_username(username) == true
        if test_new_password(username, password) == true
            add_user(username, password)
            session[:username] = username
            session[:currentuserid] = get_userid(username)
            redirect("/reviews")
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

post("/reviews") do
    if check_time(:time) == false
        set_error("DDOS")
    end
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
    get_reviews()
    slim(:reviews)
end

post("/reviews/new") do
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

get("/reviews/edit") do
    session[:old_content] = params[:content]
    db = connect_db("db/database.db")
    slim(:edit, locals:{content:old_content:})
end

post("/reviews/edit") do
    new_content = params[:content]
    db = connect_db("db/database.db")
    edit_review(new_content, :old_content)
    slim(:reviews)
end

post("/reviews/delete") do
    reviewid = params[:delete]
    db = connect_db()
    delete_review(reviewid)
    slim(:reviews)
end

get("/users") do
    db = connect_db("db/database.db")
    user_datas = get_user_datas()
    slim(:users, locals:{users:user_datas})
end

post("/users/delete") do
    userid = params[:banned]
    db = connect_db("db/database.db")
    delete_user(userid)
    slim(:users)
end
