class RenameTraitsToPromptSelections < ActiveRecord::Migration[7.1]
  def change
    rename_table :traits, :prompt_selections
    
    # Improve column naming for clarity
    rename_column :prompt_selections, :first, :tone_preference
    rename_column :prompt_selections, :second, :main_strength
    rename_column :prompt_selections, :third, :experience_level
    rename_column :prompt_selections, :fourth, :career_motivation
    
    # Add additional fields for better user profile integration
    add_column :prompt_selections, :user_id, :bigint
    add_column :prompt_selections, :is_default_profile, :boolean, default: false
    add_column :prompt_selections, :profile_name, :string
    add_column :prompt_selections, :last_used_at, :datetime
    
    # Add indexes for performance
    add_index :prompt_selections, :user_id
    add_index :prompt_selections, [:user_id, :is_default_profile]
    add_index :prompt_selections, :last_used_at
    
    # Add foreign key constraint
    add_foreign_key :prompt_selections, :users, column: :user_id
  end
end