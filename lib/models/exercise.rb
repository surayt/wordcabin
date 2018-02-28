# See https://git.weitnahbei.de/aop/wordcabin/issues/70 for specs.

module Wordcabin
  class Exercise < ActiveRecord::Base
    # id, type, name, description, text_fragment_order
    # only one of the following will be true, depending on "type"...
    has_many :text_fragments
    has_many :questions

    default_scope { order("sort_order ASC, text_fragment_order ASC, name ASC") }
        
    validates :name, presence: {message: I18n.t('models.exercise.must_be_present')}
    
    def template_name
      self.class.name.to_s.split(':').last.underscore
    end
    
    def self.types
      Exercise.descendants.map {|t| t.to_s.split('::').last}.sort
    end
  
    def url_path(method = :get)
      path = case method
        when :get    then new_record? ? 'exercises/new' : "exercises/#{id}"
        when :post   then new_record? ? 'exercises/new' : "exercises/#{id}"
        when :delete then "exercises/#{id}"
      end
      "/#{locale}/#{path}"
    end
  end

  module ExerciseTypes
    class Fake < Exercise
      belongs_to :content_fragment
      #   and uses sort_order to determine its position relative to peers
      #   and html
      # Is a placeholder which contains the HTML previously part of a
      # ContentFragment's HTML and is linked to that ContentFragment's
      # parent ContentFragment (the one with "Exercise..." in its name)
    end

    class Cloze < Exercise
      # has_many text_fragments (all of which have a sort_order)
      #   and some of which are empty, with "key" holding their intended text)
    end
    
    class DragNDropCloze < Exercise
      # has_many text_fragments (all of which have a sort_order)
      #   and some of which are empty, with "key" holding their intended text)
      # Only differs UI/view-wise
    end
    
    class SortedFragments < Exercise
      # has_many text_fragments (all of which have a sort_order)
      # has_one text_fragment_order (which is the only correct one)
    end
    
    class QuestionsAndAnswers < Exercise
      # has_many questions (using "text" for the question text
      #   and "key" for the correct answer text, once user clicks reveal button)
    end
    
    class TrueFalseQuestions < Exercise
      # has_many questions (using "text" for the question text
      #   and "key" to compare the user's answer to once user clicks reveal button)
    end
    
    class MultipleChoiceQuestions < Exercise
      # has_many questions
      # each question has_many answers (one of which is correct)
    end

    class HTML < Exercise
      # uses 'html' field
    end

    class Fake < Exercise
      # like HTML, just adds an info icon
    end
  end
end
