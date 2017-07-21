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
  end
end
