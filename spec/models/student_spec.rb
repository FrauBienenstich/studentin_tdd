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

    it 'explains models from database' do
      Student.columns = []
      expect {
        Student.explain
      }.to change {Student.columns.count}.by(3)
    end
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

  describe "#update" do
    before(:each) do
      @student = Student.new("Susanne", "Dewein" )
      @student.save
      expect(@student.id).not_to be_nil
      @student.first_name = "Hans"
      @student.last_name = "Wurst"
    end

    it 'does not add a new student to the db' do
      expect {
        @student.save
      }.not_to change{ Student.establish_db_connection.query("SELECT * from students").num_rows }
    end

    it 'changes a persisted student' do
      @student.save
      connection = Student.establish_db_connection
      result = connection.query("SELECT * FROM students WHERE id = #{@student.id}")
      expect(result.num_rows).to eq(1)
      result.each do |row|
        expect(row.join(" ")).to match /Hans Wurst/
      end
    end
  end

  describe '#delete' do
    before(:each) do
      @student = Student.new("Susanne", "Dewein")
      @student.save
    end

    it 'removes a student from the database' do
      expect {
        @student.delete
      }.to change{ Student.establish_db_connection.query("SELECT * FROM students WHERE id = #{@student.id}").num_rows }
    end
  end

  # describe '#find' do
  #   before(:each) do
  #     @student = Student.new("Susanne", "Dewein")
  #     @student.save
  #   end

  #   it 'returns a database entry' do
  #     found = Student.find(:first_name => "Sus", :last_name => "wein")
  #     found[0].first_name.should == "Susanne"
  #     found[0].should be_kind_of Student
  #     found[0].should be_persisted

  #     found = Student.find(:last_name => "nonexistent")
  #     found.should be_empty
  #   end
  # end

end

