require_relative '../spec_helpers' 
require_relative '../../models/student.rb'


describe Student do

  def truncate_table
    con = Student.establish_db_connection
    con.query("TRUNCATE table students")
  end


  after(:each) do

    truncate_table
  end

  describe "#initialize" do

    before(:each) do
      @student = Student.new("Susanne", "Dewein" )
    end

    it 'has a first_name' do
      expect(@student.first_name).to eq("Susanne")
    end

    it 'has a last_name' do
      expect(@student.last_name).to eq("Dewein")
    end

    it 'has a full name' do
      expect(@student.full_name).to eq("Susanne Dewein")
    end#this method should actually be in a different block
  end

  describe "#persisted?" do

    before(:each) do
      @student = Student.new("Susanne", "Dewein" )
      expect(@student.persisted?).to be_false
    end

    it 'is persisted with an id' do
      @student.save
      expect(@student.persisted?).to be_true
    end

    it 'saves a record in the database' do #what is the difference between this test and the one underneath?
      connection = Student.establish_db_connection
      expect {
        @student.save
      }.to change{ connection.query("SELECT * from students").num_rows }.from(0).to(1)
    end

  end

  describe "#save" do
    before(:each) do
      connection = Student.establish_db_connection
      @student = Student.new("Susanne", "Dewein" )
    end

    # it 'saves a non-persisted student to the DB' do
    #   @student.save #same as above PLUS correct entry?
    # end
  end

  describe "#update" do
    before(:each) do
      @student = Student.new("Susanne", "Dewein" )
    end

    it 'updates a persisted student in the Db' do
      connection = Student.establish_db_connection
      expect {
        @student.update 
      }.not_to change{ connection.query("SELECT * from students").num_rows }
    end
  end
end

