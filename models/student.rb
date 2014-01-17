require 'mysql'

class Student

  attr_accessor :first_name, :last_name, :id, :courses

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
    @id = id
    @courses = [] # do I need this?
  end

  def full_name
    "#{@first_name} #{@last_name}"
  end

  def persisted?
    true if @id
  end

  def save
    con = Student.establish_db_connection()
    insert_statement = con.prepare("INSERT INTO students(first_name, last_name) VALUES(?, ?);")
    insert_statement.execute @first_name, @last_name
    self.id = con.insert_id
  end

  def self.establish_db_connection(database_name)
    con = Mysql.new 'localhost', 'root', ''
    con.query("use #{database_name};")
    con.query("CREATE TABLE IF NOT EXISTS\
      students(id INT PRIMARY KEY AUTO_INCREMENT, first_name VARCHAR(20), last_name VARCHAR(20));")
    con
  end

end