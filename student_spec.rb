require './student.rb'


describe Student do

  describe "#initialize" do

    before(:each) do
      @student = Student.new("Susanne", "Dewein", 1 )
    end

      it 'has a first_name' do
        expect(@student.first_name).to eq("Susanne")
      end

      it 'has a last_name' do
        expect(@student.last_name).to eq("Dewein")

      end

      it 'has an ID' do
        expect(@student.id).to eq(1)
      end

      it 'has a full name' do
        expect(@student.full_name).to eq("Susanne Dewein")
      end#this method should actually be in a different block
  end

  describe "courses" do
    before(:each) do
      @student = Student.new("Susanne", "Dewein", 1)
      @course = Course.new("Ruby")
    end

    it 'has courses' do

    end

    # it 'can join a course' do
    #   @student.join_course(course)
    #   #expect student ... to have course..to be in array @courses?
    # end

    it 'can leave a course' do
    end

    it 'knows all its courses' do

    end

    it 'cannot join more than two courses' do

    end
  end


end