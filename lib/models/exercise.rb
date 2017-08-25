# See https://git.weitnahbei.de/aop/wordcabin/issues/70 for specs.

module Wordcabin
  class Exercise < ActiveRecord::Base
    # id, type, name, description, text_fragment_order
    # only one of the following will be true, depending on "type"...
    has_many :text_fragments
    has_many :questions
    
    validates :name, :description, presence: {message: 'must be present.'} # TODO: i18n!
    
    def template_name
      'exercises/'+self.class.name.to_s.split(':').last.split('_').first.underscore
    end
  end
  
  # DuroshoSheklArbco
  class Cloze_Exercise < Exercise
    # has_many text_fragments (all of which have a sort_order)
    #   and some of which are empty, with "key" holding their intended text)
  end
  
  # DuroshoSheklTlotho
  class DragNDropCloze_Exercise < Exercise
    # has_many text_fragments (all of which have a sort_order)
    #   and some of which are empty, with "key" holding their intended text)
    # Only differs UI/view-wise
  end
  
  # DuroshoSheklHamsho
  class SortedFragments_Exercise < Exercise
    # has_many text_fragments (all of which have a sort_order)
    # has_one text_fragment_order (which is the only correct one)
  end
  
  # DuroshoSheklHad
  class QuestionsAndAnswers_Exercise < Exercise
    # has_many questions (using "text" for the question text
    #   and "key" for the correct answer text, once user clicks reveal button)
  end
  
  # DuroshoSheklEshto
  class TrueFalseQuestions_Exercise < Exercise
    # has_many questions (using "text" for the question text
    #   and "key" to compare the user's answer to once user clicks reveal button)
  end
  
  # DuroshoSheklTre
  class MultipleChoiceQuestions_Exercise < Exercise
    # has_many questions
    # each question has_many answers (one of which is correct)
  end
end
