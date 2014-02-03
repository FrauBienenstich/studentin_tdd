require 'mysql'

module DbPersistable

  def self.included(base)
    base.extend(ClassMethods)
    base.explain
    #base.class_to_create = base
  end

  def id
    @id
  end

  def persisted?
    true if id
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

  def column_values
    variables = []
    self.class.column_titles.each do |title|
      variables << self.instance_variable_get("@#{title}").to_s
    end
    variables
  end

  def insert(con)
    keys = self.class.column_titles
    qm = self.class.question_marks(keys)

    statement = "INSERT INTO #{self.class.to_s.downcase}s (#{keys.join(', ')}) VALUES (#{qm});"

    insert_statement = con.prepare(statement)
    insert_statement.execute  *column_values 

    @id = con.insert_id
  end 

  def update(con) #--> does not go into this method!!
    values_to_set = []

    values_to_set << self.class.column_titles.map {|title| title + " = ?"}
    #puts self.class.column_titles#----> checkout colum_titles!!

    stmt = "Update #{self.class.to_s.downcase}s SET #{values_to_set.join(", ")} WHERE id = ?;"

    update_statement = con.prepare(stmt)
    vals = column_values
    vals << @id
    update_statement.execute *vals
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
      con
    end

    def columns=(val)
      @columns = val
    end

    def columns
      @columns ||= []
    end

    def explain
      begin
        con = establish_db_connection
        self.columns = []
        result = con.query("EXPLAIN #{self.to_s}s;")
        result.each do |row|
          self.columns << convert_to_hash(row) #Array mit column
        end
      rescue Mysql::Error => e
        puts e.message
      end
    end

    def column_titles
      names = []
      self.columns.each do |column|# I dont understand what is going on here
        #no columns????--> check explain!
        next if column[:is_key]
        names << column[:name]
      end
      names
    end

    def question_marks(array)
      array.map { |n| "?" }.join(", ") 
    end

    def convert_to_hash(col_info)
      {
        :name => col_info[0],
        :type => col_info[1],
        :null => (col_info[2] == "YES" ? true : false),
        :is_key => (col_info[3] == "PRI" ? true : false)
      }
    end

  end
end