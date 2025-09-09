class CreateCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.string :provider, null: false
      t.text :description
      t.string :skills, array: true, default: []
      t.decimal :rating, precision: 3, scale: 2
      t.integer :enrolled_count, default: 0
      t.integer :duration_hours
      t.string :difficulty_level
      t.string :affiliate_url, null: false
      t.decimal :price, precision: 10, scale: 2
      t.string :currency, default: 'USD'
      t.string :image_url
      t.decimal :affiliate_commission_rate, precision: 5, scale: 2
      t.boolean :active, default: true
      t.text :prerequisites
      t.text :learning_outcomes
      t.string :category
      t.string :language, default: 'en'
      t.date :last_updated

      t.timestamps
    end

    add_index :courses, :skills, using: :gin
    add_index :courses, :provider
    add_index :courses, :category
    add_index :courses, :rating
    add_index :courses, :active
    add_index :courses, [:active, :rating]
  end
end