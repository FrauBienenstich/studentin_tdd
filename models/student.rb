class Student

  attr_accessor :first_name, :last_name, :id, :courses

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
    @id = id
    @courses = [] # do I need this?
  end

  def full_name
    "#{@first_name} #{@last_name}"
  end

  def persisted?
    true if @id
  end

end