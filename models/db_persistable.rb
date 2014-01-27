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

    def find(needle)
      con = establish_db_connection
      sub_expressions = []
      needle.each do |k, v|
        sub_expressions << "#{k.to_s} like '%#{v.to_s}%'"
      end

      statement = "SELECT * FROM #{self.to_s.downcase}s WHERE #{sub_expressions.join(' AND ')};"
      result = con.query(statement)
### the stuff belwo looks ugly
      list = []

      if con.field_count == 3
        result.each do |row|
          instance = self.new(row[1], row[2])
          instance.id = row[0]
          list << instance
        end
      elsif con.field_count == 2
        result.each do |row|
        instance = self.new(row[1])
        instance.id = row[0]
        list << instance 
      end
    end
      list

    end


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