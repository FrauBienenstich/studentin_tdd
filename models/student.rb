class Student

attr_accessor :first_name, :last_name, :id, :courses

  def initialize(first_name, last_name, id)
    @first_name = first_name
    @last_name = last_name
    @id = id
    @courses = [] # do I need this?
  end

  def full_name
    "#{@first_name} #{@last_name}"
  end

  def join_course(course)
    @courses << course
  end

  def leave_course(course)
    @courses.delete(course)
  end

end