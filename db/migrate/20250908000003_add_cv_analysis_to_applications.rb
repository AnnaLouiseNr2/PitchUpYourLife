class AddCvAnalysisToApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :applications, :cv_analysis, :jsonb
    add_column :applications, :skills_gap_analysis, :jsonb
    add_column :applications, :analyzed_at, :datetime
    add_column :applications, :analysis_version, :string, default: '1.0'

    add_index :applications, :analyzed_at
    add_index :applications, :cv_analysis, using: :gin
    add_index :applications, :skills_gap_analysis, using: :gin
  end
end