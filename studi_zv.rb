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

# index => GET /students          - zeige liste
# show => GET /students/:id       - zeige details
# edit => GET /students/:id/edit  - show edit form
# new => GET /students/new        - show create form
# create => POST /students        - create form points to this
# update => PUT /students/:id     - edit form points to this
# destroy => DELETE /students/:id - delete form / link points to this