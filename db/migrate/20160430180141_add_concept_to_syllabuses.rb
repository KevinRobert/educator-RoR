class AddConceptToSyllabuses < ActiveRecord::Migration
  def change
  	add_column :syllabuses, :concept, :string
  end
end
