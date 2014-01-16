require_relative '../models/student.rb'
require "awesome_print"


describe Student do

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

    it 'should save a record in the database' do
      connection = Student.establish_db_connection("student_test")
      expect {
        @student.save
      }.to change{ connection.query("SELECT * from students").num_rows }.from(0).to(1) #compares before and after method call
    end

  end

  describe "#save" do
    before(:each) do
      @student = Student.new("Susanne", "Dewein" )
    end

    it 'saves a non-persisted student to the DB' do

    end
  end

  describe "#update" do

    it 'updates a persisted student in the Db' do
    end
  end
end

