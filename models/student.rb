require 'mysql'

class Student

  attr_accessor :first_name, :last_name, :id, :courses

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end

  # def initialize(&block)
  #   yield self
  # end

  def full_name
    "#{@first_name} #{@last_name}"
  end

  def persisted?
    true if @id
  end

  def save
    con = Student.establish_db_connection()
    persisted? ? update(con) : insert(con)
  end

  def delete
    con = Student.establish_db_connection
    delete_statement = con.prepare("DELETE FROM students WHERE id = ?;")
    delete_statement.execute @id
  end

  def self.find(needle)
    con = establish_db_connection
    sub_expressions = []
    needle.each do |k, v|
      sub_expressions << "#{k.to_s} like '%#{v.to_s}%'"
    end
    statement = "SELECT * FROM students WHERE #{sub_expressions.join(' AND ')};"
    result = con.query(statement)

    students = []    
    result.each do |row|
      s =  Student.new(row[1], row[2])
      s.id = row[0]
      students << s
    end

    students
  end


protected

  def self.establish_db_connection
    con = Mysql.new 'localhost', 'root', ''
    con.query("use #{CONFIG['database']['name']};")# still only working on the testdb?
    con.query("CREATE TABLE IF NOT EXISTS\
      students(id INT PRIMARY KEY AUTO_INCREMENT, first_name VARCHAR(20), last_name VARCHAR(20));")
    con
  end

  def insert(con)
    insert_statement = con.prepare("INSERT INTO students(first_name, last_name) VALUES(?, ?);")
    insert_statement.execute @first_name, @last_name
    self.id = con.insert_id
  end

  def update(con)
    update_statement = con.prepare("Update students SET first_name = ?, last_name = ? WHERE id = ?;")
    update_statement.execute @first_name, @last_name, @id
  end

end