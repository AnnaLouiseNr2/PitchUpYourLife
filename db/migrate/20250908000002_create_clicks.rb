class CreateClicks < ActiveRecord::Migration[7.1]
  def change
    create_table :clicks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: true, foreign_key: true
      t.references :application, null: true, foreign_key: true
      t.datetime :clicked_at, null: false
      t.string :ip_address
      t.text :user_agent
      t.string :referrer
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_campaign
      t.boolean :converted, default: false
      t.datetime :converted_at
      t.decimal :conversion_value, precision: 10, scale: 2

      t.timestamps
    end

    add_index :clicks, :clicked_at
    add_index :clicks, [:user_id, :clicked_at]
    add_index :clicks, [:course_id, :clicked_at]
    add_index :clicks, :converted
    add_index :clicks, [:converted, :converted_at]
    add_index :clicks, :utm_source
    add_index :clicks, :utm_campaign
  end
end