class Question < ActiveRecord::Base

  before_save :change_file_name

  has_many :test_questions, dependent: :destroy
  has_many :tests, through: :test_questions  
  has_one :answer, dependent: :destroy
  has_many :test_responses

  accepts_nested_attributes_for :answer

  # validation
  validates :question_type, :difficulty, :question, :presence => true

  # attachment
  has_attached_file :image, styles: { medium: "200x200>", thumb: "100x100>" }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  # pagination
  self.per_page = 25

  SUBJECTS = ["Biology", "Chemistry", "English", "Mathematics", "Physics"]
  DIFFICULTIES = ["Easy", "Moderate", "High"]
  TYPES = ["Application", "Problem", "Theory", "Analysis","Synthesis","Knowledge", "Comprehension","Evaluation"]
  ANSWER_TYPES = ["Single", "Multi", "Text", "RC"]

  def question_type=(type_array)
    type_array.reject!{ |t| t.empty? } if type_array.present?

    if type_array.present?
      write_attribute(:question_type, type_array.join(", "))
    else
      write_attribute(:question_type, "")
    end
  end

  def syllabus=(type_array)
    type_array.reject!{ |t| t.empty? } if type_array.present?

    if type_array.present?
      write_attribute(:syllabus, type_array.join(", "))
    else
      write_attribute(:syllabus, "")
    end
  end

  # bulk uploading
  def self.import(file)
    i = 0
    failed_rows = []

    return i unless file.present?

    # Populate CSV data
    CSV.read(file.path, :headers => true).each_with_index do |line, index|

      row = line.to_hash.symbolize_keys!

      concept = ""
      concept = row[:Concept_1] if row[:Concept_1].present?
      concept = concept + "," + row[:Concept_2] if row[:Concept_2].present?
      concept = concept + "," + row[:Concept_3] if row[:Concept_3].present?
      
      answers = row[:Answers].present? ? row[:Answers].split(",") : []

      #Use explicit answer type instead of deriving it
      #if !answers.present?
      #  answer_type = "Text"
      #  timed = false
      #elsif answers.length == 1
      #  answer_type = "Single"
      #  timed = true
      #else
      #  answer_type = "Multi"
      #  timed = true
      #end

      question_type = row[:Question_Type].present? ? row[:Question_Type].split(",").map(&:strip) : []

      # check question type
      unless (question_type - Question::TYPES).empty?
        failed_rows << index + 1
        next
      end

      # check syllabus
      syllabus_text = row[:Syllabus].present? ? row[:Syllabus].split(",").map(&:strip) : []
      syllabus_row = Syllabus.where("syllabus in (?)", syllabus_text)
                            .where(:subject => row[:Subject], :grade => row[:Grade], :topic => row[:topic])
      next unless syllabus_row.present?                            

      question = Question.find_by_question(row[:Question])
      unless question.present?
        question = Question.create(
          subject:      row[:Subject],
          topic:        row[:Topic],
          question_type: question_type,
          difficulty:   row[:Difficulty],
          question:     row[:Question],
          option1:      row[:Option_1],
          option2:      row[:Option_2],
          option3:      row[:Option_3],
          option4:      row[:Option_4],
          concepts:     concept,
          answer_type:  row[:Answer_Type],
          #timed:        timed,
          #timeout:      100,
          description_title:  row[:Description_Title],
          description:  row[:Description],
          solution_description:  row[:Solution_Description],
          grade:        row[:Grade],
          syllabus:     syllabus_text
        )
      else
        question.update_attributes(
          subject:      row[:Subject],
          topic:        row[:Topic],
          question_type: question_type,
          difficulty:   row[:Difficulty],
          option1:      row[:Option_1],
          option2:      row[:Option_2],
          option3:      row[:Option_3],
          option4:      row[:Option_4],
          concepts:     concept,
          answer_type:  row[:Answer_Type],
          #timed:        timed,
          #timeout:      100,
          description_title:  row[:Description_Title],
          description:  row[:Description],
          solution_description:  row[:Solution_Description],
          grade:        row[:Grade],
          syllabus:     syllabus_text
        )
      end

      if question.valid?
        Answer.create(question_id: question.id, options: answers, value: row[:answer_value])

        i = i + 1
      end
    end

    [i, failed_rows]
  end

  def get_answer_array(user_test_id, question_id)
    answers = []

    test_response = TestResponse.where(
                                  user_test_id: user_test_id,
                                  question_id: question_id
                                ).first
    if test_response.present? &&  test_response.answer_options.present?
      answers = JSON.parse(test_response.answer_options)
    end

    answers
  end

  # Search tests by syllabus, subject, grade and chapter
  def self.search(search_params)
    questions = Question.all
    questions = questions.where("subject = ?", search_params[:subject]) if search_params[:subject].present?
    questions = questions.where("question_type LIKE ?", "%#{search_params[:question_type]}%") if search_params[:question_type].present?
    questions = questions.where("difficulty = ?", search_params[:difficulty]) if search_params[:difficulty].present?
    questions = questions.where("topic = ?", search_params[:topic]) if search_params[:topic].present?
    questions = questions.where("lower(question) LIKE ?", "%#{search_params[:question].downcase}%") if search_params[:question].present?
    questions = questions.where("grade = ?", search_params[:grade]) if search_params[:grade].present?

    questions
  end

  private

  def change_file_name
    new_file_name = self.subject + "-" + self.topic
    if self.image.present? && !self.image_file_name.start_with?(new_file_name) 
      
      new_file_name = self.subject + "-" + self.topic + "-" + self.image_file_name
      self.image_file_name = new_file_name
    end
  end

end