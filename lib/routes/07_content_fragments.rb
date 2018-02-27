require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application

    # ContentFragment routes. Must come last. And careful with these as their order is important!
    
    get '/:book' do |book|
      book = ContentFragment.book(locale, book)
      if book && book.first_child
        location = book.first_child.url_path
      else
        book = ContentFragment.new(book: I18n.t('models.content_fragment.new_book_title'), locale: I18n.locale)
        if current_user.is_admin?
          location = "/#{locale}/new?content_fragment[book]=#{book.book}&content_fragment[locale]=#{book.locale}&view_mode=edit"
        else
          flash[:warn] = I18n.t('routes.book_is_empty')
          location = '/'
        end
      end
      redirect to(location)
    end
    
    # Routes that must cater to both ContentFragments as well as Exercises
    
    get /\/(new|(.*)\/(.*))/ do
      # Exercise
      if params[:exercise]
        redirect back # TODO: read params[exercise][type] and make it so that the correct form is displayed
      # ContentFragment
      else
        __new__, book, chapter = params['captures']
        if book && chapter
          @fragment = ContentFragment.chapter(locale, book, chapter)
        else
          params[:content_fragment] ||= {}
          params[:content_fragment][:locale] = locale
          @fragment = ContentFragment.new(params[:content_fragment])
        end
        if @fragment
          @toc = TOC.new(locale, @fragment.parent)
          # TODO: the below condition always returns `false'. Find out why
          # Sinatra is unable to recognize XHR requests and then fix up the
          # JavaScript that is _supposed_ to parse JSON, but is no parsing
          # HTML instead...
          request.xhr? ? haml(:article, layout: false) : haml(:contents, locals: {model: :content_fragment})
        else
          flash[:error] = I18n.t('routes.no_such_chapter')
          redirect to('/')
        end
      end
    end
    
    post /\/(new|(.*))/ do
      __new__, id = params['captures']
      if __new__ && __new__ == 'new'
        params[:content_fragment].merge!(locale: locale) if params[:content_fragment][:locale].blank?
        @fragment = ContentFragment.new(params[:content_fragment])
      else
        @fragment = ContentFragment.find(id)
        @fragment.update_attributes(params[:content_fragment])
      end
      if @fragment
        if published = params[:parent_is_published]
          @fragment.parent.update_attribute(:is_published, published == 'true' ? true : false)
        end
        if @fragment.save
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
    
  # TODO: re-enable when deleting is properly implemented UI-wise
=begin
    delete '/:id' do |id|
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
=end
  end
end
