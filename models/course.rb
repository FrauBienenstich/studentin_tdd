class Course

attr_accessor :title, :id

  def initialize(title)
    @title = title
    #@id = id --> this was actually needed before @id showed up in #peristed?
  end

  def persisted?
    true if @id
  end

  def save
    con = Course.establish_db_connection
    persisted? ? update(con) : insert(con)

  end


  def delete
    con = Course.establish_db_connection
    delete_statement = con.prepare("DELETE FROM courses WHERE id = ?;")
    delete_statement.execute @id
  end

  def self.find(needle)
    con = establish_db_connection
    sub_expressions = []
    needle.each do |k, v|
      sub_expressions << "#{k.to_s} like '%#{v.to_s}%'" #name like susanne
    end

    statement = "SELECT * FROM courses WHERE #{sub_expressions.join(' AND ')};"
    result = con.query(statement) #sql statement

    courses = []
    result.each do |row|
      c = Course.new(row[1])
      c.id = row[0]
      courses << c
    end # courses as objects

    courses
  end


  protected

  def self.establish_db_connection
    con = Mysql.new 'localhost', 'root', ''
    con.query("use #{CONFIG['database']['name']};")
    con.query("CREATE TABLE IF NOT EXISTS\
      courses(id INT PRIMARY KEY AUTO_INCREMENT, title VARCHAR(20));")
    con
  end

  def insert(con)
    insert_statement = con.prepare("INSERT INTO courses(title) VALUES(?);")
    insert_statement.execute @title
    self.id = con.insert_id
  end

  def update(con)
    update_statement = con.prepare("UPDATE courses SET title = ? WHERE id = ?;")
    update_statement.execute @title, @id
  end

end