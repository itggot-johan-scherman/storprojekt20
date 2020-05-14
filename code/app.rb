require_relative './model.rb'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'

enable :sessions

include Model

# Displays the error page, also checks the time to deny a potential DDOS upon further errors
# 
# @param [String] error, The message to be displayed
def set_error(error)
    slim(:error, locals:{message:error})
    session[:time] = Time.now.to_i
end

# Displays landing page
#
get("/") do
    slim(:index)
end

# Creates a new user and redirects to the review page
#
# @param [String] username, the submitted username
# @param [String] password, the submitted password
# @param [String] password_match, submitted password confirmation
# @see Model#test_new_username
# @see Model#test_new_password
# @see Model#get_userid
# @see Model#admin_check
post("/users/new") do
    if check_time(session[:time]) == false
        set_error("DDOS")
    end
    username = params[:username]
    password = params[:password]
    password_match = params[:password_match]
    new_user_result = test_new_username(username)
    if new_user_result == true
        new_password_result = test_new_password(password, password_match)
        if  new_password_result == true
            add_user(username, password)
            session[:username] = username
            session[:currentuserid] = get_userid(username)
            session[:admin] = admin_check(username)
            redirect("/reviews")
        elsif new_password_result == false
            set_error("Different passwords!")
        else
            set_error("Something went wrong :(")
        end
    elsif new_user_result == false
        set_error("That username is taken!")
    else
        set_error("Something went wrong :(")
    end
end

# Authorizes and validates the user trying to log in and redirects to the review page if everything is correct
#
# @param [String] username, the submitted username
# @param [String] password, the submitted password
#
# @see Model#test_username
# @see Model#test_password
# @see Model#get_userid
# @see Model#admin_check
post("/reviews") do
    if check_time(session[:time]) == false
        set_error("DDOS")
    end
    username = params[:username]
    password = params[:password]
    user_result = test_username(username)
    if user_result == true
        password_result = test_password(username, password)
        if password_result == true
            session[:username] = username
            session[:currentuserid] = get_userid(username)
            session[:admin] = admin_check(username)
            redirect("/reviews")
        elsif password_result == false
            set_error("Wrong password!")
        else
            set_error("Something went wrong")
        end
    elsif user_result == false
        set_error("User does not exist")
    else
        set_error("Something went wrong")
    end
end

# Displays the main review page
#
# @see Model#get_reviews
get("/reviews") do
    datas = get_reviews()
    slim(:reviews, locals:{datas:datas})
end

# Creates a new review and redirects to an updated review page
#
# @param [string] title, the submitted title
# @param [string] genre, the submitted genre
# @param [string] review, the content of the submitted review
#
# @see Model#get_genres
# @see Model#add_genre
# @see Model#get_genreid
# @see Model#get_titles
# @see Model#add_title
# @see Model#get_titleid
# @see Model#get_userid
# @see Model#add_review
post("/reviews/new") do
    title = params[:title]
    genre_temp = params[:genre]
    genre_arr = genre_temp.split(', ')
    review = params[:review]
    title_check = get_titles()
    title_matches = []
    title_check.each do |element|
        title_matches << /#{title}/.match(element["title"])
    end
    if !title_matches.any?
        add_title(title)
    end
    titleid = get_titleid(title)
    p title
    p titleid
    genre_check = get_genres()
    relations_check = get_relations(titleid)
    genre_arr.each do |genre|
        genre_matches = []
        genre_check.each do |element|
            genre_matches << /#{genre}/.match(element["genre"])
        end
        if !genre_matches.any?
            add_genre(genre)
        end
        genreid = get_genreid(genre)
        relation_matches = []
        relations_check.each do |item|
            relation_match = /#{genreid.to_s}/.match(item["genreid"].to_s)
            relation_matches << relation_match
        end
        if !relation_matches.any?
            add_relation(titleid, genreid)
        end
    end
    userid = get_userid(session[:username])
    add_review(review, userid, titleid)
    redirect("/reviews")
end

# Displays the page for editing an existing review
#
get("/reviews/edit") do
    session[:old_content] = params[:content]
    session[:edit_id] = params[:id]
    slim(:edit)
end

# Replaces an existing review with a new edited one, then redirects to the review page.
#
# @param [String] new_content, the new review being put into place
# 
# @see Model#edit_review
post("/reviews/edit") do
    new_content = params[:new_content]
    edit_id = session[:edit_id]
    edit_review(new_content, edit_id)
    redirect("/reviews")
end

# Removes an existing review and redirects to an updated review page.
#
# @param [Integer] reviewid, the ID of the review to be deleted
#
# @see Model#delete_review
post("/reviews/delete") do
    reviewid = params[:delete]
    delete_review(reviewid)
    redirect("/reviews")
end

# Displays a list of all users, and links to delete them.
#
# @see Model#get_user_datas
get("/users") do
    user_datas = get_user_datas()
    slim(:users, locals:{users:user_datas})
end

# Deletes a user and all of their reviews, then redirects to the user page. (not working :/)
#
# @param [String] userid, the ID user to be removed
#
# @see Model#delete_user
post("/users/delete") do
    userid = params[:banned]
    delete_user(userid)
    redirect("/users")
end
