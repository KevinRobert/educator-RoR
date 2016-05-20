class CreateSyllabuses < ActiveRecord::Migration
  def change
    create_table :syllabuses do |t|
      t.string :syllabus
      t.string :grade
      t.string :subject
      t.string :topic
    end
  end
end
