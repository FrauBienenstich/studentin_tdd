require_relative '../spec_helpers' 
require_relative '../../models/db_persistable.rb'

describe DbPersistable do

  class Dummy
    include DbPersistable
    attr_accessor :dog_name, :dog_age, :dog_color, :id
  end

  before :all do
    con = Dummy.establish_db_connection
    con.query("CREATE TABLE IF NOT EXISTS dummys (id INT PRIMARY KEY AUTO_INCREMENT, dog_name VARCHAR(20), dog_age VARCHAR(20), dog_color INT);")
  end

  after :each do
    con = Dummy.establish_db_connection
    con.query("TRUNCATE TABLE dummys;")
  end


  it 'explains models from database' do
    Dummy.columns = []
    expect {
      Dummy.explain
    }.to change {Dummy.columns.count}.by(4)
  end

  it 'converts explain arrays into hashes' do
    result = Dummy.convert_to_hash( ["dog_color", "int(11)", "YES", "", nil, ""])
    #ap Dummy.columns
    #puts "DUMMY EXPLAIN"
    #puts Dummy.explain
    result.should == {
      :name => "dog_color",
      :type => "int(11)",
      :null => true,
      :is_key => false
    }
  end

  context "generate insert statement" do

    before do
      Dummy.explain
    end

    it 'generates a list of column names used for insert statement' do
      #ap Dummy.column_titles
      expect(Dummy.column_titles).to eq %w{dog_name dog_age dog_color} 
    end

    it 'generates a list of values used for insert statement' do
      susi = Dummy.new
      susi.dog_name = "Susi"
      susi.dog_age = 3
      susi.dog_color = 2
      expect(susi.column_values).to eq ["Susi", "3", "2"]
    end

    it 'generates an array with the right amount of question marks' do
      expect(Dummy.question_marks([1,2,3])).to eq "?, ?, ?"
    end

    it 'inserts the correct data into the db' do
      susi = Dummy.new
      susi.dog_name = "Susi"
      susi.dog_age = 3
      susi.dog_color = 2

      con = Dummy.establish_db_connection
      expect {
        susi.insert(con)
      }.to change{ con.query("SELECT * from dummys").num_rows}.from(0).to(1)      
    end

  end

  context "generate update statement" do
    before(:each) do
      @con = Dummy.establish_db_connection
      @susi = Dummy.new
      @susi.dog_name = "Susi"
      @susi.dog_age = 3
      @susi.dog_color = 2
      @susi.save
    end
    
    it 'it changes a persisted entry' do
      @susi.dog_name = "Schmusi"
      @susi.update(@con)
      result = @con.query("SELECT * FROM dummys WHERE id = #{@susi.id}")
      expect(result.num_rows).to eq(1)
      result.each do |row|
        expect(row.join(" ")).to match /Schmusi 3 2/
      end
    end

    it 'does not add a new entry' do
      @susi.dog_name = "Schmusi"
      expect {
        @susi.update(@con)
      }.not_to change{ Dummy.establish_db_connection.query("SELECT * from dummys").num_rows}

    end
  end


  describe "#save" do

    before(:each) do
      # @con = Dummy.establish_db_connection
      # wieso muss ich table NOCHMAL droppen etc? habe doch before und after hook oben
      # @con.query("DROP TABLE dummys;")
      # @con.query("CREATE TABLE IF NOT EXISTS dummys (id INT PRIMARY KEY AUTO_INCREMENT, dog_name VARCHAR(20), dog_age VARCHAR(20), dog_color INT);")
      @susi = Dummy.new
      @susi.dog_name = "Susi"
      @susi.dog_age = 3
      @susi.dog_color = 2
      expect(@susi.persisted?).to be_false
    end

    it 'is persisted with an id' do
      @susi.save
      expect(@susi.persisted?).to be_true
    end

    it 'saves a record in the database' do #what is the difference between this test and the one underneath?
      connection = Dummy.establish_db_connection
      expect {
        @susi.save
      }.to change{ connection.query("SELECT * from dummys").num_rows }.from(0).to(1)
    end

  end

  describe "#delete" do
    before(:each) do
      @susi = Dummy.new
      @susi.dog_name = "Susi"
      @susi.dog_age = 3
      @susi.dog_color = 2

      @susi.save
    end

    it 'removes an entry from the database' do
      expect {
        @susi.delete
      }.to change{ Dummy.establish_db_connection.query("SELECT * FROM dummys WHERE id = #{@susi.id}").num_rows }
    end

  end

  describe "#find" do
    before(:each) do 
      @susi = Dummy.new
      @susi.dog_name = "Susi"
      @susi.dog_age = 3
      @susi.dog_color = 2
      @susi.save
    end

    it 'returns a database entry' do
      puts Dummy.establish_db_connection.query("SELECT count(*) FROM dummys").num_rows
      found = Dummy.find(:dog_name => "Su", :dog_color => 2)
      found[0].should be_kind_of Dummy
      found[0].should be_persisted
      found[0].dog_name.should == "Susi"

      found = Dummy.find(:dog_name => "nonexistant")
      found.should be_empty
    end

  end
end