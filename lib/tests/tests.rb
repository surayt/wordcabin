ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'pathname'
require 'simple-random'
MAIN_CONFIG = Pathname('../../config')+'config.rb'
require_relative MAIN_CONFIG
require_relative Config.lib+'server.rb'

module SinatraApp
  class SinatraAppTest < MiniTest::Test
    include Rack::Test::Methods
    
    def app
      Server
    end
    
    def some_integer
      @rand.uniform(2,9999999).to_i
    end
    
    def some_book
      "book#{some_integer}"
    end
    
    def some_chapter
      segments = @rand.uniform(1, 10).to_i
      chapter = ''
      segments.times {chapter << "#{@rand.uniform(1,999).to_i}."}
      chapter.chomp '.'
    end
    
    def some_locale
      locales = [:de, :en, :tr, :ar, :sv, :nl, :fr]
      locales.sample
    end
    
    def setup
      ContentFragment.delete_all
      @book1 = ContentFragment.create(locale: :en, book: 'book1', chapter: nil)
      @rand = SimpleRandom.new
      @rand.set_seed
    end
    
    # --------------------------------------------------------------------------
    # lib/models/content_fragment.rb
    # --------------------------------------------------------------------------
    
    def test_can_create_valid_content_fragment
      c = ContentFragment.new(locale: @book1.locale, book: @book1.book, chapter: some_chapter)
      assert c.save
    end
    
    def test_fails_when_creating_content_fragment_without_locale
      c = ContentFragment.new(locale: nil, book: some_book)
      assert c.save == false
    end
    
    def test_fails_when_creating_content_fragment_without_book
      c = ContentFragment.new(locale: some_locale, book: nil)
      assert c.save == false
    end
    
    def test_fails_when_creating_content_fragment_with_subtly_illegal_chapter_format
      c = ContentFragment.new(locale: some_locale, book: some_book, chapter: '1.2.3,4')
      assert c.save == false
    end
    
    def test_fails_when_creating_content_fragment_with_chapter_that_already_exists_in_the_scope_of_locale_and_book
      chapter = some_chapter
      c1 = ContentFragment.new(locale: @book1.locale, book: @book1.book, chapter: chapter)
      c2 = ContentFragment.new(locale: @book1.locale, book: @book1.book, chapter: chapter)
      assert c1.save == true
      assert c2.save == false
    end
    
    def test_its_possible_to_create_two_content_fragments_with_consecutive_chapter_numbers
      c1 = ContentFragment.new(locale: @book1.locale, book: @book1.book, chapter: '1.2.3.4')
      c2 = ContentFragment.new(locale: @book1.locale, book: @book1.book, chapter: '1.2.3.5')
      assert c1.save == true
      assert c2.save == true
    end
    
    def test_its_possible_to_delete_a_fragment_without_children
      c = ContentFragment.new(locale: @book1.locale, book: @book1.book, chapter: some_chapter)
      assert c.save == true
      c.destroy
      assert c.errors.any? == false
    end
    
    def test_its_impossible_to_delete_a_fragment_with_children
      parent = ContentFragment.new(locale: @book1.locale, book: @book1.book, chapter: '10')
      sibling = ContentFragment.new(locale: @book1.locale, book: @book1.book, chapter: '11')
      child = ContentFragment.new(locale: @book1.locale, book: @book1.book, chapter: '10.5')
      assert parent.save == true
      assert sibling.save == true
      assert child.save == true
      initial_count = ContentFragment.count
      parent.destroy
      assert_equal initial_count, ContentFragment.count
      child.destroy
      parent.destroy
      assert_equal initial_count - 2, ContentFragment.count
    end
    
    def test_its_possible_to_change_a_fragments_chapter
      c = ContentFragment.new(locale: @book1.locale, book: @book1.book, chapter: '2.3.4.5')
      assert c.save == true
      assert c.update_attribute(:chapter, '2.3.4.6') == true
    end
    
    # --------------------------------------------------------------------------
    # lib/routes.rb
    # TODO: Implement all of these!
    # --------------------------------------------------------------------------
    
    def test_get_slash_if_no_content_fragments_present
      # User should see an empty index page.
    end
    
    def test_get_slash_if_only_one_book_fragment_present
      # User should see one entry on the index page,
      # which, when clicked, redirects to the index page and
      # an error message appears saying the book is still empty.
    end
    
    def test_get_slash_if_only_one_book_and_one_child_fragment_present
      # User should see one entry on the index page,
      # which, when clicked, should bring the user to
      # that book's first child fragment.
    end
    
    def test_login_if_no_content_fragments_present
      # After login,
      # user should be redirected to "/:locale/new" and
      # form should be completely empty.
      #
      # After saving, user should be redirected to "/:locale/new" and
      # form should be filled with book that was just created and
      # with chapter "1".
    end
    
    def test_adding_new_content_fragment_to_existing_book_with_one_child
      # After pressing "Add Content Fragment" button,
      # user should see "/:locale/new" and
      # form should be filled with book from last selected ContentFragment and
      # chapter should be +1 to that of the last selected ContentFragment.
    end
  end
end
