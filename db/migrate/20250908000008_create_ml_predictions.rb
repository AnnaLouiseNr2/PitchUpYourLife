class CreateMlPredictions < ActiveRecord::Migration[7.1]
  def change
    create_table :ml_predictions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :application, null: false, foreign_key: true
      
      # Prediction types and results
      t.string :prediction_type, null: false # success_probability, salary_range, career_path
      t.decimal :success_probability, precision: 5, scale: 4 # 0.0000 to 1.0000
      t.jsonb :salary_prediction # {min: 75000, max: 95000, currency: 'USD'}
      t.jsonb :career_paths # Array of career progression predictions
      t.decimal :confidence_score, precision: 3, scale: 2 # 0.00 to 1.00
      
      # Model metadata
      t.string :model_version
      t.jsonb :model_metadata # Feature importance, model details
      t.jsonb :input_features # Features used for prediction
      
      # Status and processing
      t.string :status, default: 'pending' # pending, processing, completed, failed
      t.text :error_message
      t.datetime :processed_at
      t.integer :processing_duration_ms
      
      t.timestamps
    end
    
    # Indexes for efficient queries
    add_index :ml_predictions, [:user_id, :prediction_type]
    add_index :ml_predictions, [:application_id, :prediction_type]
    add_index :ml_predictions, :status
    add_index :ml_predictions, :confidence_score
    add_index :ml_predictions, :processed_at
    add_index :ml_predictions, :salary_prediction, using: :gin
    add_index :ml_predictions, :career_paths, using: :gin
    add_index :ml_predictions, :model_metadata, using: :gin
  end
end