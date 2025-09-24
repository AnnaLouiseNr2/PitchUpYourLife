class CreateTraitsTable < ActiveRecord::Migration[7.1]
  def change
    # This migration is no longer needed as traits have been renamed to prompt_selections
    # The prompt_selections table already exists in the schema
  end
end
