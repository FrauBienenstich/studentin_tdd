require_relative '../spec_helpers' 
require_relative '../../models/course.rb'

describe Course do

  def truncate_table
    con = Course.establish_db_connection
    con.query("TRUNCATE table courses")
  end


  after(:each) do
    truncate_table
  end

  describe "initialize" do

    before(:each) do
      @course = Course.build(:title => "Ruby")
    end

    it "has a title" do
      expect(@course.title).to eq("Ruby")
    end

  end

  describe "#persisted?" do

    before(:each) do
      @course = Course.build(:title => "Ruby")
      @course.persisted? == false
    end

  end

  # describe '#update' do

  #   before(:each) do
  #     @course = Course.new("Ruby")
  #     @course.save
  #     expect(@course.id).not_to be_nil 
  #     @course.title = "Fuby"
  #   end

  #   it ' does not add a new course' do
  #     expect {
  #       @course.save
  #     }.not_to change{ Course.establish_db_connection.query("SELECT * from courses").num_rows}
  #   end

  #   it 'changes a persisted entry' do
  #     @course.save
  #     connection = Course.establish_db_connection
  #     result = connection.query("SELECT * FROM courses WHERE id = #{@course.id}")
  #     expect(result.num_rows).to eq(1)
  #     result.each do |row|
  #       expect(row.join).to match /Fuby/
  #     end
  #   end

  # end


  # describe '#find' do
  #   before(:each) do
  #     @course = Course.new("Ruby")
  #     @course.save

  #   end
  #   it 'returns course from database' do
  #     found = Course.find(:title => "Ruby")
  #     expect(found[0].title).to eq("Ruby")
  #     expect(found[0]).to be_a_kind_of Course
  #     expect(found[0]).to be_persisted

  #     found = Course.find(:title => "nonexistant")
  #     expect(found).to be_empty
  #   end
  # end

end
