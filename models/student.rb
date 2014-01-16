class Student

attr_accessor :first_name, :last_name, :id

  def initialize(first_name, last_name, id)
    @first_name = first_name
    @last_name = last_name
    @id = id
  end

  def full_name
    "#{@first_name} #{@last_name}"
  end

end