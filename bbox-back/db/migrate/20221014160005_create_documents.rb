class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.string :filename
      t.float :size
      t.string :location

      t.timestamps
    end
  end
end
