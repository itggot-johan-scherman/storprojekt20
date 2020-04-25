def connect_db(route)
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    return db
end

def check_time(time)
    check = Time.now - time
    if check > 1
        return true
    else 
        return false
    end
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

def get_reviewid(new_content, old_content)
    db.execute("REPLACE review FROM reviews (old_content, new_content)")
end

def add_review()
    db.execute("INSERT INTO reviews (content, userid, titleid, genreid) VALUES (?, ?, ?, ?)", review, userid, titleid, genreid)
end

def delete_review(reviewid)
    db.execute("REMOVE * FROM reviews WHERE reviewid = ?", reviewid)
end

def get_reviews()
    reviews = db.execute("SELECT reviewid FROM reviews")
    session[:datas] = []
    reviews.each do |element|
        reviewid = element[0][0]
        data = db.execute("SELECT * FROM reviews WHERE reviewid = ?", reviewid)
        title = db.execute("SELECT title FROM titles WHERE titleid = ?", data[2][0])
        genre = db.execute("SELECT genre FROM genres WHERE genreid = ?", data[4][0])
        user = db.execute("SELECT user FROM users WHERE userid = ?", data[3][0])
        content = data[1][0]
        userid = data[3][0]
        data_arr = [userid, genre, title, user, content, reviewid]
        :datas << data_arr
    end
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
    
    if password_match == password
        password_digest = BCrypt::Password.create(password)
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
        return false
    end
end



def test_password(username, password)
    digest_check = get_password_digest(username)
    digest_test = BCrypt::Password.new(digest_check)
    digest_temp = BCrypt::Password.create(password)
    if digest_test == digest_temp
        
        return true
    else
        return false
    end
end

def add_user(username, password)
    password_digest = BCrypt::Password.create(password)
    db.execute("INSERT INTO users (username, password_digest) VALUES (?, ?)", username, password_digest)
end

def admin_check(username)
    db.execute("SELECT admin FROM users WHERE username = ?", username)[0][0]
end

def get_user_datas()
    db.execute("SELECT * FROM users")
end

def delete_user(userid)
    db.execute("REMOVE * FROM (users, reviews) WHERE userid = ?", userid)
end