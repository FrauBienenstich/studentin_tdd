require 'sinatra'
require 'haml'

require_relative 'config/environment'
require_relative 'models/student'
require_relative 'models/course'

get '/' do 
  @students = Student.all
  @courses = Course.all
  haml :index, :format => :html5
end

get '/students/new' do
  @student = Student.new
  @course = Course.new
  haml :new, :format => :html5
end

post '/students' do
  @student = Student.build(params[:student])
  @student.save
  redirect '/'
end

delete '/students/:id' do
  puts params.inspect
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