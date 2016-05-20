class AddImageToQuestions < ActiveRecord::Migration
  def up
    add_attachment :questions, :image
  end

  def down
    remove_attachment :questions, :image
  end
end
