require 'csv'

namespace :sample do

  desc 'Populate sample questions data into DB'
  task populate_questions: :environment do

    # populate sample test
    sample_test = Test.find_or_create_by(name: 'Sample', subject: 'Physics', syllabus: 'Foundation', topic: 'Math')
    parse_csv('db/data/sample_questions.csv', sample_test)

    # populate chemistry test
    chemistry_test = Test.find_or_create_by(name: 'Chemistry 10th Grade', subject: 'Chemistry', syllabus: 'Foundation', topic: 'Chemistry')
    parse_csv('db/data/chemistry.csv', chemistry_test)

    # populate physics 10th grade test
    physics_test = Test.find_or_create_by(name: 'Physics 10th Grade', subject: 'Physics', syllabus: 'Foundation', topic: 'Physics')
    parse_csv('db/data/physics.csv', physics_test)    

    # populate General Entrance test
    general_test = Test.find_or_create_by(name: 'Entrance Exam', subject: 'General', syllabus: 'Foundation', topic: 'Physics')
    parse_csv('db/data/general.csv', general_test)  
  end

  def parse_csv(file_name, test)
    test.questions.destroy_all
    # Populate CSV data
    CSV.read(file_name, :headers => true).each_with_index do |line, index|

      row = line.to_hash.symbolize_keys!

      concept = ""
      concept = concept + "," + row[:Concept_1] if row[:Concept_1].present?
      concept = concept + "," + row[:Concept_2] if row[:Concept_2].present?
      concept = concept + "," + row[:Concept_3] if row[:Concept_3].present?

      answers = row[:answers].present? ? row[:answers].split(",") : []
      if !answers.present?
        answer_type = "Text"
        timed = false
      elsif answers.length == 1
        answer_type = "Single"
        timed = true
      else
        answer_type = "Multi"
        timed = true
      end

      question = Question.create(
        si_no:        row[:SI_No],
        subject:      row[:Subject],
        topic:        row[:Topic],
        question_type: row[:Question_Type],
        difficulty:   row[:Difficulty],
        question:     row[:Question],
        option1:      row[:Option_1],
        option2:      row[:Option_2],
        option3:      row[:Option_3],
        option4:      row[:Option_4],
        concepts:     concept,
        answer_type:  answer_type,
        timed:        timed,
        timeout:      100,
        description_title:  row[:Description_Title],
        description:  row[:Description]
      )

      if question.valid?
        Answer.create(question_id: question.id, options: answers, value: row[:answer_value])
        TestQuestion.create(test_id: test.id, question_id: question.id)
      end
    end
  end

  desc 'Populate sample school data into DB'
  task populate_schools: :environment do
    school = School.find_by_name('No School Affiliation')
    School.create(:name => 'No School Affiliation', :grade10 => true) unless school.present?
    school = School.find_by_name('Kamala Niketan')
    School.create(:name => 'Kamala Niketan', :grade10 => true) unless school.present?
  end

  desc 'Populate sample sections data into DB'
  task populate_sections: :environment do
    section = Section.find_by_name('Class A')
    Section.create(:name => 'Class A', :grade => '10th', :school_id => '2') unless section.present?
    section = Section.find_by_name('Class B')
    Section.create(:name => 'Class B', :grade => '10th', :school_id => '2') unless section.present?  
  end

end