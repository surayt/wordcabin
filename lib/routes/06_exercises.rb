require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application
    
    # These must come before ContentFragment routes.
    # Otherwise basic CRUD here.
    
    get '/exercises' do
      if current_user.is_admin?
        find_exercises
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
      puts "GET /exercises/new".red
      puts params[:exercise].inspect.red
      if current_user.is_admin?
        find_exercises
        if @exercise = Exercise.new(params[:exercise])
          haml :'contents', locals: {model: :exercise}
        else
          # TODO: come up with more fitting error message.
          flash[:error] = I18n.t('routes.no_such_exercise')
          redirect to('/')
        end
      end
    end
    
    post '/exercises/new' do
      puts "POST /exercises/new".red
      puts params[:exercise].inspect.red
      @exercise = Exercise.new(params[:exercise])
      if @exercise.save
        flash[:notice] = I18n.t('routes.exercise_saved')
        redirect_opts = {
          locale: @exercise.locale,
          type: @exercise.type, 
          content_fragment_id: @exercise.content_fragment_id,
          sort_order: @exercise.sort_order ? @exercise.sort_order+1 : 0
        }
        redirect_opts = redirect_opts.map {|k,v| "exercise[#{k}]=#{v}"}.join('&')
        redirect_string = "/#{@exercise.locale}/exercises/new?#{redirect_opts}"
        redirect to(redirect_string)
      else
        flash[:error] = @exercise.errors.full_messages.join(', ')
        redirect back
      end
    end
    
    get '/exercises/:id' do |id|
      @exercise = Exercise.find(id)
      @questions = @exercise.questions
      @text_fragments = @exercise.text_fragments
      if current_user.is_admin? && !request.xhr?
        find_exercises
        haml :'contents', locals: {model: :exercise}
      else
        haml :"exercises/view", locals: {exercise: @exercise}, layout: false
      end
    end
    
    post '/exercises/:id' do |id|
    end
    
    delete '/exercises/:id' do |id|
      @exercise = Exercise.find(id)
      if @exercise.destroy
        flash[:notice] = "Exercise has been destroyed." # TODO: I18n!
      end
    end
    
    private
    
    def find_exercises
      @exercises = Exercise.where(locale: session[:content_locale])
      @exercise_types = Exercise.types
      @content_fragments = ContentFragment.where(locale: session[:content_locale])
    end
  end
end
