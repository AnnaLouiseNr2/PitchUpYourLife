class RenameClToCoverletter < ActiveRecord::Migration[7.1]
  def change
    # Rename application columns
    rename_column :applications, :cl_message, :coverletter_message
    rename_column :applications, :cl_status, :coverletter_status
    
    # Rename finals columns
    rename_column :finals, :cl, :coverletter_content
    
    # Drop the redundant cls table since we're using finals for final content
    drop_table :cls do |t|
      t.references :application, null: false, foreign_key: true
      t.string :title
      t.text :content
      t.timestamps
    end
  end
end