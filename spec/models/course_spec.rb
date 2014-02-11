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

end
