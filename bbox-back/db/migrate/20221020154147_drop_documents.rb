class DropDocuments < ActiveRecord::Migration[7.0]
  def change
    drop_table(:documents)
  end
end
