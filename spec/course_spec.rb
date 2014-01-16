require_relative '../models/course.rb'
describe Course do
  describe "initialize" do
    before(:each) do
      @course = Course.new("Ruby")
    end

    it "has a title" do
      expect(@course.title).to eq("Ruby")
    end

  end
end
