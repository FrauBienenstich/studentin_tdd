require 'sinatra'
require 'haml'
require 'active_support/all'

require_relative 'config/environment'
require_relative 'models/student'
require_relative 'models/course'

get '/' do 
  @students = Student.all
  @courses = Course.all
  haml :index, :format => :html5
end

get "/:model/new" do # students vs courses? check new form
  @model_name = params[:model].downcase.singularize #zb course
  @klass = @model_name.camelcase.constantize #Course
  @instance = @klass.new #Course.new


  # fallse nich kapierst:
  # case params[:model].downcase
  # when "student"
  #   puts "Student"
  #   @student = Student.new
  # when "course"
  #   puts "Course"
  #   @course = Course.new
  # end

  # params[:model]
  # @student = Student.new
  # @course = Course.new
  haml :new, :format => :html5
end

post "/:model" do
  @model_name = params[:model].downcase.singularize
  @klass = @model_name.camelcase.constantize

  @instance = @klass.build(params[@model_name])# hash with indifferent access, nochmal anschauen
  @instance.save
  redirect '/'
end

# post '/students' do
#   @student = Student.build(params[:student])
#   @student.save
#   redirect '/'
# end

delete '/students/:id' do
  students = Student.find(:id => params[:id]) #has to be a hash!, returns array with objects
  students[0].destroy unless students.length == 0 # do not delete array but object in it!
  redirect '/'
end

get '/students/:id' do
  @student = Student.find(:id => params[:id])
  haml :show, :format => :html5
end

get '/students/:id/edit' do
  students = Student.find(:id => params[:id])
  @student = students[0]

  haml :edit, :format => :html5
end

put '/students/:id' do
  students = Student.find(:id => params[:id])
  @student = students[0]
  @student.update_attributes(params[:student])
  @student.save
  redirect '/'
end

# post '/courses/new' do
#   @course = Course.build(params[:course])
#   @course.save
#   redirect '/'
# end

# index => GET /students          - zeige liste
# show => GET /students/:id       - zeige details
# edit => GET /students/:id/edit  - show edit form
# new => GET /students/new        - show create form
# create => POST /students        - create form points to this
# update => PUT /students/:id     - edit form points to this
# destroy => DELETE /students/:id - delete form / link points to this