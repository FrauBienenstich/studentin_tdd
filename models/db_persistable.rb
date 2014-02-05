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

    def build(properties)
      instance = new
      properties.each do |k, v|
        # call the setter method
        instance.send("#{k}=", v)
      end
      instance
    end

    def with_db(&block)
      con = establish_db_connection
      block.call(con)
      con.close
    end

    def find(needle)

      sub_expressions = []
      #             k           v
      # needle:  {:dog_name => "Su"}
      needle.each do |k, v|
        #puts "the column name: #{k}"
        #puts "our columns: #{columns.inspect}"

        #[
        #  {:name=>"id", :type=>"int(11)", :null=>false, :is_key=>true}, 
        #  {:name=>"dog_name", :type=>"varchar(20)", :null=>true, :is_key=>false}, 
        #  {:name=>"dog_age", :type=>"varchar(20)", :null=>true, :is_key=>false},
        #  {:name=>"dog_color", :type=>"int(11)", :null=>true, :is_key=>false}
        #]

        #find the column info for our needle
        colInfo = columns.find {|i| i[:name] == k.to_s}
        #puts "the column info: #{colInfo.inspect}"
        
        if colInfo[:type].start_with? "int"
          sub_expressions << "#{k.to_s} = #{v.to_s}"
        else
          sub_expressions << "#{k.to_s} like '%#{v.to_s}%'"
        end
        
      end
      statement = "SELECT * FROM #{self.to_s.downcase}s WHERE #{sub_expressions.join(' AND ')};"
      result = query(statement)
      convert_result_to_object(result)
    end

    def query(statement)
      result = nil
      
      with_db do |con|
        result = con.query(statement)
      end
      result
    end

    def convert_result_to_object(result)
      list = []

      #full column names with id
      col_names = columns.map{ |i| i[:name] }

      result.each do |row|
        properties = Hash[*col_names.zip(row).flatten] #returns hash?
        instance = new

        properties.each do |k, v|
          instance.instance_variable_set("@#{k}", v)
        end

        puts instance.inspect
        list << instance

        # this is what it actually means
        # properties = {:name => "value"}
        # @student #instance
        # @student.@name = properties[:name]
      end
      list
    end

    def all
      result_set = query("select * from #{self.to_s.downcase}s")
      obj = convert_result_to_object(result_set)
      puts obj.inspect
      obj
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
      self.columns.each do |column|
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