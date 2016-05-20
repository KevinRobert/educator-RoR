class AddSiNoToTestQuestions < ActiveRecord::Migration
  def up
    add_column :test_questions, :si_no, :string
    add_column :test_questions, :position, :integer

    remove_column :questions, :si_no
    remove_column :questions, :position

    TestQuestion.select("test_id").group("test_id").each do |test_id|
      
      test_questions = TestQuestion.where(:test_id => test_id.test_id).order(id: :asc)
      test_questions.each_with_index do |tq, tq_index|
        tq.update_attributes(:si_no => "Q#{(tq_index + 1).to_s.rjust(2, "0")}")
      end
    end
  end

  def down
    remove_column :test_questions, :si_no
    remove_column :test_questions, :position

    add_column :questions, :si_no, :string
    add_column :questions, :position, :integer
  end
end
