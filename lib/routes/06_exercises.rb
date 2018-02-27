require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application
    
    # Exercise routes. Must come before ContentFragment routes.
    
    get '/exercises' do
      if current_user.is_admin?
        @exercises = Exercise.all
        @exercise_types = Exercise.types
        haml :contents, locals: {model: :exercise}
      else
        redirect to('/')
      end
    end
    
    # TODO: find out why Sinatra can't recognize XHR requests
    # and re-integrate this tidbit with the regular one above.
    # First hints: HTTP_X_REQUESTED_WITH is lacking from both
    # headers{} and env{}.
    get '/exercises.json' do
      if current_user.is_admin?
        Exercise.all.map {|e| {text: e.name, value: e.id}}.to_json
      end
    end
    
    get '/exercises/:id' do |id|
      @exercises = Exercise.all
      @exercise_types = Exercise.types
      begin
        @exercise = @exercises.find(id)
        @text_fragments = @exercise.text_fragments
        @questions = @exercise.questions
        if params[:view_mode] == 'edit' && current_user.is_admin?
          haml :contents, locals: {model: :exercise}
        else
          haml @exercise.template_name.to_sym, layout: false
        end
      rescue ActiveRecord::RecordNotFound
        "No such exercise!" # TODO: proper error message required, but not sure yet where it will appear...
      end
    end
  end
end
