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

get "/:model/new" do 
  @model_name = params[:model].downcase.singularize #zb course
  @klass = @model_name.camelcase.constantize #Course
  @instance = @klass.new #Course.new

  haml :new, :format => :html5
end

post "/:model" do
  @model_name = params[:model].downcase.singularize
  @klass = @model_name.camelcase.constantize

  @instance = @klass.build(params[@model_name])# hash with indifferent access, nochmal anschauen
  @instance.save
  redirect '/'
end

delete '/:model/:id' do
  @model_name = params[:model].downcase.singularize
  @klass = @model_name.camelcase.constantize

  entries = @klass.find(:id => params[:id]) #has to be a hash!, returns array with objects
  entries[0].destroy unless entries.length == 0 # do not delete array but object in it!
  redirect '/'
end

get '/:model/:id' do
  @model_name = params[:model].downcase.singularize #TODO tbc
  @klass = @model_name.camelcase.constantize

  list = @klass.find(:id => params[:id])
  @instance = list[0]
  haml :show, :format => :html5
end

get '/:model/:id/edit' do
  @model_name = params[:model].downcase.singularize
  @klass = @model_name.camelcase.constantize

  list = @klass.find(:id => params[:id])
  @instance = list[0]

  haml :edit, :format => :html5
end

put '/:model/:id' do
  @model_name = params[:model].downcase.singularize
  @klass = @model_name.camelcase.constantize

  list = @klass.find(:id => params[:id])
  @instance = list[0]
  @instance.update_attributes(params[@model_name])
  @instance.save
  redirect '/'
end

# index => GET /students          - zeige liste
# show => GET /students/:id       - zeige details
# edit => GET /students/:id/edit  - show edit form
# new => GET /students/new        - show create form
# create => POST /students        - create form points to this
# update => PUT /students/:id     - edit form points to this
# destroy => DELETE /students/:id - delete form / link points to this