# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_09_08_000008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "applications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "job_d"
    t.integer "stage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "coverletter_message"
    t.string "coverletter_status", default: "pending", null: false
    t.text "video_message"
    t.string "video_status", default: "pending", null: false
    t.text "name"
    t.text "title"
    t.jsonb "cv_analysis"
    t.jsonb "skills_gap_analysis"
    t.datetime "analyzed_at"
    t.string "analysis_version", default: "1.0"
    t.index ["analyzed_at"], name: "index_applications_on_analyzed_at"
    t.index ["cv_analysis"], name: "index_applications_on_cv_analysis", using: :gin
    t.index ["skills_gap_analysis"], name: "index_applications_on_skills_gap_analysis", using: :gin
    t.index ["user_id"], name: "index_applications_on_user_id"
  end

  create_table "clicks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id"
    t.bigint "application_id"
    t.datetime "clicked_at", null: false
    t.string "ip_address"
    t.text "user_agent"
    t.string "referrer"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_campaign"
    t.boolean "converted", default: false
    t.datetime "converted_at"
    t.decimal "conversion_value", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_clicks_on_application_id"
    t.index ["clicked_at"], name: "index_clicks_on_clicked_at"
    t.index ["converted", "converted_at"], name: "index_clicks_on_converted_and_converted_at"
    t.index ["converted"], name: "index_clicks_on_converted"
    t.index ["course_id", "clicked_at"], name: "index_clicks_on_course_id_and_clicked_at"
    t.index ["course_id"], name: "index_clicks_on_course_id"
    t.index ["user_id", "clicked_at"], name: "index_clicks_on_user_id_and_clicked_at"
    t.index ["user_id"], name: "index_clicks_on_user_id"
    t.index ["utm_campaign"], name: "index_clicks_on_utm_campaign"
    t.index ["utm_source"], name: "index_clicks_on_utm_source"
  end

  create_table "courses", force: :cascade do |t|
    t.string "title", null: false
    t.string "provider", null: false
    t.text "description"
    t.string "skills", default: [], array: true
    t.decimal "rating", precision: 3, scale: 2
    t.integer "enrolled_count", default: 0
    t.integer "duration_hours"
    t.string "difficulty_level"
    t.string "affiliate_url", null: false
    t.decimal "price", precision: 10, scale: 2
    t.string "currency", default: "USD"
    t.string "image_url"
    t.decimal "affiliate_commission_rate", precision: 5, scale: 2
    t.boolean "active", default: true
    t.text "prerequisites"
    t.text "learning_outcomes"
    t.string "category"
    t.string "language", default: "en"
    t.date "last_updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "rating"], name: "index_courses_on_active_and_rating"
    t.index ["active"], name: "index_courses_on_active"
    t.index ["category"], name: "index_courses_on_category"
    t.index ["provider"], name: "index_courses_on_provider"
    t.index ["rating"], name: "index_courses_on_rating"
    t.index ["skills"], name: "index_courses_on_skills", using: :gin
  end

  create_table "finals", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "coverletter_content"
    t.text "pitch"
    t.integer "coverletter_version", default: 1
    t.integer "pitch_version", default: 1
    t.datetime "finalized_at"
    t.bigint "finalized_by_user_id"
    t.boolean "is_current", default: true
    t.integer "coverletter_word_count"
    t.integer "pitch_word_count"
    t.jsonb "generation_metadata"
    t.index ["application_id", "is_current"], name: "index_finals_on_application_id_and_is_current"
    t.index ["application_id"], name: "index_finals_on_application_id"
    t.index ["finalized_at"], name: "index_finals_on_finalized_at"
    t.index ["generation_metadata"], name: "index_finals_on_generation_metadata", using: :gin
    t.index ["is_current"], name: "index_finals_on_is_current"
  end

  create_table "ml_predictions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "application_id", null: false
    t.string "prediction_type", null: false
    t.decimal "success_probability", precision: 5, scale: 4
    t.jsonb "salary_prediction"
    t.jsonb "career_paths"
    t.decimal "confidence_score", precision: 3, scale: 2
    t.string "model_version"
    t.jsonb "model_metadata"
    t.jsonb "input_features"
    t.string "status", default: "pending"
    t.text "error_message"
    t.datetime "processed_at"
    t.integer "processing_duration_ms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id", "prediction_type"], name: "index_ml_predictions_on_application_id_and_prediction_type"
    t.index ["application_id"], name: "index_ml_predictions_on_application_id"
    t.index ["career_paths"], name: "index_ml_predictions_on_career_paths", using: :gin
    t.index ["confidence_score"], name: "index_ml_predictions_on_confidence_score"
    t.index ["model_metadata"], name: "index_ml_predictions_on_model_metadata", using: :gin
    t.index ["processed_at"], name: "index_ml_predictions_on_processed_at"
    t.index ["salary_prediction"], name: "index_ml_predictions_on_salary_prediction", using: :gin
    t.index ["status"], name: "index_ml_predictions_on_status"
    t.index ["user_id", "prediction_type"], name: "index_ml_predictions_on_user_id_and_prediction_type"
    t.index ["user_id"], name: "index_ml_predictions_on_user_id"
  end

  create_table "pitches", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.string "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_pitches_on_application_id"
  end

  create_table "prompt_selections", force: :cascade do |t|
    t.text "tone_preference"
    t.text "main_strength"
    t.text "experience_level"
    t.text "career_motivation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "application_id"
    t.bigint "user_id"
    t.boolean "is_default_profile", default: false
    t.string "profile_name"
    t.datetime "last_used_at"
    t.index ["application_id"], name: "index_prompt_selections_on_application_id"
    t.index ["last_used_at"], name: "index_prompt_selections_on_last_used_at"
    t.index ["user_id", "is_default_profile"], name: "index_prompt_selections_on_user_id_and_is_default_profile"
    t.index ["user_id"], name: "index_prompt_selections_on_user_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "videos", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_videos_on_application_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "applications", "users"
  add_foreign_key "clicks", "applications"
  add_foreign_key "clicks", "courses"
  add_foreign_key "clicks", "users"
  add_foreign_key "finals", "applications"
  add_foreign_key "finals", "users", column: "finalized_by_user_id"
  add_foreign_key "ml_predictions", "applications"
  add_foreign_key "ml_predictions", "users"
  add_foreign_key "pitches", "applications"
  add_foreign_key "prompt_selections", "applications"
  add_foreign_key "prompt_selections", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "videos", "applications"
end
