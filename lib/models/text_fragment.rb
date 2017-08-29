# See https://git.weitnahbei.de/aop/wordcabin/issues/70 for specs.

module Wordcabin
  class TextFragment < ActiveRecord::Base
    # id, text, key, sort_order
    # foreign_key must be specified so belongs_to isn't fooled by Exercise's STI model
    belongs_to :exercise, foreign_key: :exercise_id
    # for answer, foreign_key specified so belongs_to isn't fooled by _this_ STI model
    belongs_to :question, foreign_key: :question_id
    # for question
    has_many :answers, foreign_key: :question_id
    
    def text
      unless text_ltr.nil? || text_ltr.strip.blank? || text_rtl.nil? || text_rtl.strip.blank?
        s = [text_ltr, text_rtl].join(' ') 
      end
    end

    def key
      unless key_ltr.nil? || key_ltr.strip.blank? || key_rtl.nil? || key_rtl.strip.blank?
        s = [key_ltr, key_rtl].join(' ')
      end
    end
  end
  
  class Question < TextFragment
    # if text is empty, key must not be
    # has_many answers
  end
  
  class Answer < TextFragment
    # key must be empty
    # belongs_to answer
  end
end
