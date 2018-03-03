require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application

    # Careful with these as their order is important. This file must also be the last of the routing files!
    # Otherwise basic CRUD here.    

    get '/content_fragments/new' do
      params[:content_fragment] ||= {}
      params[:content_fragment][:locale] ||= locale
      if @fragment = ContentFragment.new(params[:content_fragment])
        @toc = TOC.new(locale, @fragment.parent)
        haml :'contents', locals: {model: :content_fragment}
      else
        # TODO: come up with more fitting error message.
        flash[:error] = I18n.t('routes.no_such_chapter')
        redirect to('/')
      end
    end
    
    post '/content_fragments/new' do
      params[:content_fragment][:locale] ||= locale
      if @fragment = ContentFragment.new(params[:content_fragment])
        if @fragment.save
          flash[:notice] = I18n.t('routes.fragment_saved')
          redirect to("#{URI.escape(@fragment.url_path)}?view_mode=preview")
        else
          flash[:error] = @fragment.errors.full_messages.join(', ')
          redirect back
        end
      else
        flash[:error] = I18n.t('routes.fragment_not_found')
        redirect back
      end
    end
    
    post '/content_fragments/:id' do |id|
      if @fragment = ContentFragment.find(id)
        if @fragment.update_attributes(params[:content_fragment])
          if published = params[:parent_is_published]
            unless @fragment.parent.update_attribute(:is_published, published == 'true' ? true : false)
              flash[:error] = I18n.t('routes.could_not_publish')
            end
          end
          flash[:notice] = I18n.t('routes.fragment_saved')
          redirect to("#{URI.escape(@fragment.url_path)}?view_mode=preview")          
        else
          # TODO: Not (visually) pretty, but whatever.
          flash[:error] = @fragment.errors.full_messages.join(' ')
          redirect back
        end
      else
        flash[:error] = I18n.t('routes.fragment_not_found')
        redirect back
      end      
    end

    delete '/content_fragments/:id' do |id|
      if @fragment = ContentFragment.find(id)
        if @fragment.destroy
          flash[:notice] = I18n.t('routes.fragment_destroyed')
        else
          flash[:error] = I18n.t('routes.fragment_cant_be_destroyed')
        end
      else
        flash[:error] = I18n.t('routes.fragment_not_found')
      end
      redirect back
    end

    get '/:book' do |book|
      begin
        book = ContentFragment.book(locale, book)
        location = book.first_child.url_path
      rescue
        if current_user.is_admin?
          location = "/#{locale}/content_fragments/new?view_mode=edit"
        else
          flash[:warn] = I18n.t('routes.book_is_empty')
          location = '/'
        end
      end
      redirect to(location)
    end    

    get '/:book/:chapter' do |book, chapter|
      if @fragment = ContentFragment.chapter(locale, book, chapter)
        @toc = TOC.new(locale, @fragment.parent)
        if request.xhr?
          puts "content_fragments: Processing request as XHR, returning HTML without layout".green
          haml :'content_fragments/view', layout: false
        else
          puts "content_fragments: Processing request normally, returning HTML with layout".green
          haml :'contents', locals: {model: :content_fragment}
        end
      else
        flash[:error] = I18n.t('routes.no_such_chapter')
        redirect to('/')
      end
    end
  end
end
