class RestructureFinalsTable < ActiveRecord::Migration[7.1]
  def change
    # Add more descriptive columns to finals table
    add_column :finals, :coverletter_version, :integer, default: 1
    add_column :finals, :pitch_version, :integer, default: 1
    add_column :finals, :finalized_at, :datetime
    add_column :finals, :finalized_by_user_id, :bigint
    add_column :finals, :is_current, :boolean, default: true
    
    # Add metadata for tracking changes
    add_column :finals, :coverletter_word_count, :integer
    add_column :finals, :pitch_word_count, :integer
    add_column :finals, :generation_metadata, :jsonb
    
    # Add indexes for performance
    add_index :finals, :finalized_at
    add_index :finals, :is_current
    add_index :finals, [:application_id, :is_current]
    add_index :finals, :generation_metadata, using: :gin
    
    # Add foreign key for finalized_by_user
    add_foreign_key :finals, :users, column: :finalized_by_user_id
  end
end