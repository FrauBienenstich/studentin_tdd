require_relative '../spec_helpers' 
require_relative '../../models/db_persistable.rb'

describe DbPersistable do

  class Dummy
    include DbPersistable
    attr_accessor :dog_name, :dog_age, :dog_color
  end

  before :all do
    con = Dummy.establish_db_connection
    con.query("CREATE TABLE IF NOT EXISTS dummys (id INT PRIMARY KEY AUTO_INCREMENT, dog_name VARCHAR(20), dog_age VARCHAR(20), dog_color INT);")
  end

  after :all do
    con = Dummy.establish_db_connection
    con.query("DROP TABLE dummys;")
  end

  it 'explains models from database' do
    expect {
      Dummy.explain
    }.to change {Dummy.columns.count}.by(4)
  end

  it 'converts explain arrays into hashes' do
    result = Dummy.convert_to_hash( ["dog_color", "int(11)", "YES", "", nil, ""])
    ap Dummy.columns
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
      expect(Dummy.column_titles).to eq %w{dog_name dog_age dog_color} 
    end

    it 'generates a list of values used for insert statement' do
      susi = Dummy.new
      susi.dog_name = "Susi"
      susi.dog_age = 3
      susi.dog_color = 2
      expect(susi.column_values).to eq ["Susi", "3", 2]
    end
  end

end