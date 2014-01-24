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

  # def save
  #   con = Student.establish_db_connection()
  #   persisted? ? update(con) : insert(con)
  # end

  module ClassMethods    
  end
end