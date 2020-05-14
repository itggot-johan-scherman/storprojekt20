module Model

    # Connects the database
    #
    # @param [String] route the path where the database is located
    #
    # @return [Hash] db the database in the form of a hash
    def connect_db(route)
        db = SQLite3::Database.new(route)
        db.results_as_hash = true
        return db
    end

    def check_time(time)
        if time != nil
            check = (Time.now.to_i - time)
            if check > 1
                return true
            else 
                return false
            end
        end
    end

    def get_userid(username)
        db = connect_db("db/database.db")
        nil_check = db.execute("SELECT userid FROM users WHERE username = ?", username)
        if nil_check.any?
            return nil_check[0][0]
        else
            return nil_check
        end
    end

    def get_password_digest(username)
        db = connect_db("db/database.db")
        db.execute("SELECT password_digest FROM users WHERE username = ?", username)[0][0]
    end

    def get_genres()
        db = connect_db("db/database.db")
        db.execute("SELECT genre FROM genres")
    end

    def add_genre(genre)
        db = connect_db("db/database.db")
        db.execute("INSERT INTO genres (genre) VALUES (?)", genre)
    end

    def add_relation(titleid, genreid)
        db = connect_db("db/database.db")
        db.execute("INSERT INTO relations (titleid, genreid) VALUES (?, ?)", titleid, genreid)
    end

    def get_genreid(genre)
        db = connect_db("db/database.db")
        db.execute("SELECT genreid FROM genres WHERE genre = ?", genre)[0][0]
    end

    def get_titles()
        db = connect_db("db/database.db")
        db.execute("SELECT title FROM titles")
    end

    
    def add_title(title, genreid)
        db = connect_db("db/database.db")
        db.execute("INSERT INTO titles (title, genreid) VALUES (?, ?)", title, genreid)
    end

    def get_titleid(title)
        db = connect_db("db/database.db")
        db.execute("SELECT titleid FROM titles WHERE title = ?", title)[0][0]
    end

    def edit_review(new_content, edit_id)
        db = connect_db("db/database.db")
        db.execute("UPDATE reviews SET content = ? WHERE reviewid = ?", new_content, edit_id)
    end

    def add_review(review, userid, titleid)
        db = connect_db("db/database.db")
        db.execute("INSERT INTO reviews (content, userid, titleid) VALUES (?, ?, ?)", review, userid, titleid)
    end

    def delete_review(reviewid)
        db = connect_db("db/database.db")
        db.execute("DELETE FROM reviews WHERE reviewid = ?", reviewid)
    end

    def get_reviews()
        db = connect_db("db/database.db")
        reviews = db.execute("SELECT reviewid FROM reviews")
        datas = []
        reviews.each do |element|
            reviewid = element[0]
            data = db.execute("SELECT * FROM reviews WHERE reviewid = ?", reviewid)[0]
            title = db.execute("SELECT title FROM titles WHERE titleid = ?", data[2])[0]["title"]
            genreid = db.execute("SELECT genreid FROM relations WHERE titleid = ?", data[2])
            genre = []
            genreid.each do |i|
                item = db.execute("SELECT genre FROM genres WHERE genreid = ?", i[0])
                genre << item[0][0]
            end
            user = db.execute("SELECT username FROM users WHERE userid = ?", data[3])[0]["username"]
            content = data[1]
            userid = data[3]
            data_arr = [userid, genre.join(', '), title, user, content, reviewid]
            datas << data_arr
        end
        return datas
    end

    def test_new_username(username)
        p username
        user_check = get_userid(username)
        if !user_check.any? 
            return true
        else
            return false
        end
    end

    def test_new_password(password, password_match)
        if password_match == password
            return true
        else
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
        if digest_test == password
            return true
        else
            return false
        end
    end

    def add_user(username, password)
        password_digest = BCrypt::Password.create(password)
        db = connect_db("db/database.db")
        db.execute("INSERT INTO users (username, password_digest, admin) VALUES (?, ?, ?)", username, password_digest, "false")
    end

    def admin_check(username)
        db = connect_db("db/database.db")
        db.execute("SELECT admin FROM users WHERE username = ?", username)[0][0]
    end

    def get_user_datas()
        db = connect_db("db/database.db")
        db.execute("SELECT * FROM users WHERE admin = ?", "false")
    end

    def delete_user(userid)
        db = connect_db("db/database.db")
        db.execute("DELETE FROM (users, reviews) WHERE userid = ?", userid)
    end

end