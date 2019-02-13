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
          Exercise.all.map {|e| {text: e.name, value: e.id}}.to_json
        else
          content_type :html
          haml :'exercises'
        end
      else
        redirect to('/')
      end
    end
    
    get '/exercises/new' do
      if current_user.is_admin?
        find_exercises
        if new_exercise 
          haml :'exercises'
        else
          # TODO: come up with more fitting error message.
          flash[:error] = I18n.t('routes.no_such_exercise')
          redirect to('/')
        end
      end
    end
    
    post '/exercises/new' do
      @exercise = Exercise.new(params[:exercise])
      if @exercise.save
        flash[:notice] = 'Exercise created.' # TODO: I18n!
        redirect to("/#{@exercise.locale}/exercises/new?view_mode=edit")
      else
        flash[:error] = @exercise.errors.full_messages.join(', ')
        redirect back
      end
    end
    
    get '/exercises/:id' do |id|
      begin
        @exercise = Exercise.find(id)
      rescue
        flash[:error] = "No such exercise." # TODO: I18n!
        redirect to("/#{locale}/exercises")
      end
      @questions = @exercise.questions
      @text_fragments = @exercise.text_fragments
      if current_user.is_admin? && !request.xhr?
        find_exercises
        d "routes/exercises: Returning exercise with layout"
        haml :'exercises'
      else
        d "routes/exercises: Returning exercise without layout"
        haml :"exercises/view", layout: false
      end
    end
    
    post '/exercises/:id' do |id|
      @exercise = Exercise.find(id)
      if @exercise.update_attributes(params[:exercise])
        flash[:notice] = 'Exercise was updated.' # TODO: I18n!
        redirect to(@exercise.url_path+"?view_mode=edit")
      else
        flash[:error] = @exercise.errors.full_messages.join(', ')
        redirect back
      end
    end
    
    delete '/exercises/:id' do |id|
      @exercise = Exercise.find(id)
      if @exercise.destroy
        flash[:notice] = "Exercise has been destroyed." # TODO: I18n!
      end
    end
    
    private
    
    def find_exercises
      # all exercise types that are technically available
      @exercise_types = Exercise.types

      # the list of exercises to be displayed
      @exercises = Exercise.where(locale: session[:content_locale])
      @book = ContentFragment.books(session[:content_locale]).first
      
      # the list of content fragments an exercise could be attached to, if desired
      @content_fragments = ContentFragment.where(locale: session[:content_locale])

      # what content fragment is the last exercise in the current list attached to?
      # or even better: which one did the last exercise freshly created get attached to?
      # TODO: this is ugly. it should not be
      @content_fragment = ContentFragment.find(
        (params[:exercise] && params[:exercise][:content_fragment_id]) \
          ? params[:exercise][:content_fragment_id]                    \
          : (@exercises.last.content_fragment_id || nil)
      )
    end

    def new_exercise
      # TODO: this is ugly. it should not be
      @exercise = Exercise.new(
        type: ExerciseTypes::Fake,
        locale: session[:content_locale],
        content_fragment_id: @content_fragment.id, 
        sort_order: @exercises.last                                             \
          ? (@exercises.last.sort_order ? @exercises.last.sort_order + 1 : nil) \
          : nil
      )
    end
  end
end
