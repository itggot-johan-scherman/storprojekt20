require 'sinatra'
require 'slim'
require 'sqlite3'
require 'BCrypt'
enable :sessions

get("/") do
    slim(:index)
end

post("/reviews/") do
    username = params[:username]
    password = params[:password]
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new("db/tododatabase.db")
    db.results_as_hash = true
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