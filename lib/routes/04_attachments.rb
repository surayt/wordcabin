require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application

    # FileAttachment routes. Must come before ContentFragment routes.
    
    get '/files/:id.?:extension?' do |id,ext| # second one is unused
      begin
        file = FileAttachment.find(id)
        headers['Content-Type'] = file.content_type
        file.binary_data
      rescue ActiveRecord::RecordNotFound
        flash[:warning] = I18n.t('routes.attached_file_not_found')
      end
    end
    
    post '/files' do
      begin
        params[:document][:file][:content_type] = params[:document][:file][:type]
        file = FileAttachment.new(params[:document][:file])
        if file.save
          json(document: {
            url: file.url_path,
            title: params['document']['title']
          })
        else
          msg = file.errors.full_messages.first
          json(error: {message: msg})
        end
      rescue => e
        msg = I18n.t('routes.file_upload_500', error: e)
        json(error: {message: msg}) 
      end
    end
  end
end
