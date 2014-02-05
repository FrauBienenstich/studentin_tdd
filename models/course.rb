require_relative './db_persistable.rb'
class Course


  attr_accessor :title, :id
  include DbPersistable

  # def initialize(properties)
  #   @title = properties[:title]
  # end


end