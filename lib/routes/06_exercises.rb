require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application
    
    # These must come before ContentFragment routes.
    # Otherwise basic CRUD here.
    
    get '/exercises' do
      if current_user.is_admin?
        @exercises = Exercise.all
        @exercise_types = Exercise.types
        if request.xhr?
          content_type :json
          puts "exercises: Processing request as XHR, returning JSON".green
          Exercise.all.map {|e| {text: e.name, value: e.id}}.to_json
        else
          content_type :html
          puts "exercises: Processing request normally, returning HTML".green
          haml :'contents', locals: {model: :exercise}
        end
      else
        redirect to('/')
      end
    end
    
    get '/exercises/new' do
      if current_user.is_admin?
        @exercises = Exercise.all
        @exercise_types = Exercise.types
        params[:exercise][:locale] ||= locale
        params[:exercise][:type] = params[:exercise][:type].prepend("Wordcabin::ExerciseTypes::")
        if @exercise = Exercise.new(params[:exercise])
          #begin
            haml :'contents', locals: {model: :exercise}
          #rescue
          #  flash[:error] = I18n.t('routes.exercise_type_not_yet_fully_implemented')
          #  redirect back
          #end
        else
          flash[:error] = I18n.t('routes.no_such_exercise') # TODO: come up with more fitting error message.
          redirect to('/')
        end
      end
    end
    
    post '/exercises/new' do
    end
    
    get '/exercises/:id' do |id|
      @exercises = Exercise.all
      @exercise_types = Exercise.types
      begin
        @exercise = @exercises.find(id)
        @text_fragments = @exercise.text_fragments
        @questions = @exercise.questions
        if params[:view_mode] == 'edit' && current_user.is_admin?
          haml :'contents', locals: {model: :exercise}
        else
          haml :"exercises/edit/#{@exercise.template_name}", layout: false
        end
      rescue ActiveRecord::RecordNotFound
        "No such exercise!" # TODO: proper error message required, but not sure yet where it will appear...
      end
    end
    
    post '/exercises/:id' do |id|
    end
    
    delete '/exercises/:id' do |id|
    end
  end
end
