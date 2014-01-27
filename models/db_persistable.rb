require 'mysql'

module DbPersistable

  def self.included(base)
    base.extend(ClassMethods)
    #base.class_to_create = base
  end

  def persisted?
    true if @id
  end


  def save
    con = self.class.establish_db_connection
    persisted? ? update(con) : insert(con)
  end

  def delete
    con = self.class.establish_db_connection
    delete_statement = con.prepare("DELETE FROM #{self.class.to_s.downcase}s WHERE id = ?;")
    delete_statement.execute @id
  end

  module ClassMethods 


    def establish_db_connection
      con = Mysql.new 'localhost', 'root', ''
      con.query("use #{CONFIG['database']['name']};")

      if self.class == Course
        con.query("CREATE TABLE IF NOT EXISTS\
          #{self.class.to_s.downcase}s(id INT PRIMARY KEY AUTO_INCREMENT, title VARCHAR(20));")
      elsif self.class == Student
        con.query("CREATE TABLE IF NOT EXISTS\
          #{self.class.to_s.downcase}s(id INT PRIMARY KEY AUTO_INCREMENT, first_name VARCHAR(20), last_name VARCHAR(20));")
      end
      con
    end


  end
end