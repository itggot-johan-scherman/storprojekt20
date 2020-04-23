def connect_db(route)
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    return db
end

def get_userid(username)
    db.execute("SELECT userid FROM users WHERE username = ?", username)[0][0]
end

def get_password_digest(username)
    db.execute("SELECT password_digest FROM users WHERE username = ?", username)[0][0]
end

def get_genres()
    db.execute("SELECT genre FROM genres")
end

def add_genre(genre)
    db.execute("INSERT INTO genres (genre) VALUES (?)", genre)
end

def get_genreid(genre)
    db.execute("SELECT genreid FROM genres WHERE genre = ?", genre)[0][0]
end

def get_titles()
    db.execute("SELECT title FROM titles")
end

def add_title(title, genreid)
    db.execute("INSERT INTO titles (title, genreid) VALUES (?, ?)", title, genreid)
end

def get_titleid(title)
    db.execute("SELECT titleid FROM titles WHERE title = ?", title)[0][0]
end

def add_review()
    db.execute("INSERT INTO reviews (content, userid, titleid, genreid) VALUES (?, ?, ?, ?)", review, userid, titleid, genreid)
end

def test_new_username(username)
    user_check = get_userid(username)
    if user_check !.any? 
        return true
    else
        return false
    end
end

def test_new_password(password, password_match)
    password_digest = BCrypt::Password.create(password)
    if password_match == password
        add_user(username, password_digest)
        userid = get_userid(username)
        return true
        redirect("/newuser")
    else
        set_error("Different passwords!")
        return false
    end
end

def test_username(username)
    user_check = get_userid(username)
    if user_check != nil
        return true
    else
        #set_error("User does not exist")
        return false
    end
end



def test_password(username, password)
    digest_check = get_password_digest(username)
    digest_test = BCrypt::Password.new(digest_check)
    digest_temp = BCrypt::Password.create(password)
    if digest_test == digest_temp
        #session[:username] = username
        #session[:currentuserid] = user_check
        #redirect("/reviews")
        return true
    else
        #set_error("Wrong password!")
        return false
    end
end


def add_user(username, password_digest)
    db.execute("INSERT INTO users (username, password_digest) VALUES (?, ?)", username, password_digest)
end