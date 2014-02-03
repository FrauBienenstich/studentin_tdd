require_relative './db_persistable.rb'

class Student

  attr_accessor :first_name, :last_name, :id, :courses
  include DbPersistable

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end

  def full_name
    "#{@first_name} #{@last_name}"
  end

end