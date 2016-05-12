# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160512173700) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "batch_items", force: :cascade do |t|
    t.boolean  "dpla",                  default: false, null: false
    t.boolean  "public",                default: false, null: false
    t.text     "dc_format",             default: [],    null: false, array: true
    t.text     "dc_identifier",         default: [],    null: false, array: true
    t.text     "dc_right",              default: [],    null: false, array: true
    t.text     "dc_date",               default: [],    null: false, array: true
    t.text     "dc_relation",           default: [],    null: false, array: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "batch_id",                              null: false
    t.integer  "collection_id",                         null: false
    t.string   "other_collections",     default: [],                 array: true
    t.string   "slug",                                  null: false
    t.text     "dcterms_is_part_of",    default: [],    null: false, array: true
    t.text     "dcterms_contributor",   default: [],    null: false, array: true
    t.text     "dcterms_creator",       default: [],    null: false, array: true
    t.text     "dcterms_description",   default: [],    null: false, array: true
    t.text     "dcterms_extent",        default: [],    null: false, array: true
    t.text     "dcterms_medium",        default: [],    null: false, array: true
    t.text     "dcterms_identifier",    default: [],    null: false, array: true
    t.text     "dcterms_language",      default: [],    null: false, array: true
    t.text     "dcterms_spatial",       default: [],    null: false, array: true
    t.text     "dcterms_publisher",     default: [],    null: false, array: true
    t.text     "dcterms_access_right",  default: [],    null: false, array: true
    t.text     "dcterms_rights_holder", default: [],    null: false, array: true
    t.text     "dcterms_subject",       default: [],    null: false, array: true
    t.text     "dcterms_temporal",      default: [],    null: false, array: true
    t.text     "dcterms_title",         default: [],    null: false, array: true
    t.text     "dcterms_type",          default: [],    null: false, array: true
    t.text     "dcterms_is_shown_at",   default: [],    null: false, array: true
    t.text     "dcterms_provenance",    default: [],    null: false, array: true
    t.text     "dcterms_license",       default: [],    null: false, array: true
    t.integer  "item_id"
  end

  add_index "batch_items", ["batch_id"], name: "index_batch_items_on_batch_id", using: :btree
  add_index "batch_items", ["item_id"], name: "index_batch_items_on_item_id", using: :btree
  add_index "batch_items", ["slug"], name: "index_batch_items_on_slug", using: :btree

  create_table "batches", force: :cascade do |t|
    t.string   "name",                           null: false
    t.text     "notes"
    t.datetime "committed_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "user_id"
    t.json     "commit_results",    default: {}, null: false
    t.integer  "batch_items_count", default: 0
  end

  add_index "batches", ["user_id"], name: "index_batches_on_user_id", using: :btree

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.string   "user_type"
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "document_type"
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id", using: :btree

  create_table "collections", force: :cascade do |t|
    t.integer   "repository_id"
    t.boolean   "in_georgia",            default: true,  null: false
    t.boolean   "remote",                default: false, null: false
    t.text      "display_title",                         null: false
    t.text      "short_description"
    t.text      "teaser"
    t.string    "color"
    t.text      "dc_format",             default: [],    null: false, array: true
    t.text      "dc_identifier",         default: [],    null: false, array: true
    t.text      "dc_right",              default: [],    null: false, array: true
    t.text      "dc_date",               default: [],    null: false, array: true
    t.daterange "date_range"
    t.datetime  "created_at",                            null: false
    t.datetime  "updated_at",                            null: false
    t.text      "dc_relation",           default: [],    null: false, array: true
    t.string    "other_repositories",    default: [],                 array: true
    t.boolean   "public",                default: false, null: false
    t.string    "slug",                                  null: false
    t.text      "dcterms_is_part_of",    default: [],    null: false, array: true
    t.text      "dcterms_contributor",   default: [],    null: false, array: true
    t.text      "dcterms_creator",       default: [],    null: false, array: true
    t.text      "dcterms_description",   default: [],    null: false, array: true
    t.text      "dcterms_extent",        default: [],    null: false, array: true
    t.text      "dcterms_medium",        default: [],    null: false, array: true
    t.text      "dcterms_identifier",    default: [],    null: false, array: true
    t.text      "dcterms_language",      default: [],    null: false, array: true
    t.text      "dcterms_spatial",       default: [],    null: false, array: true
    t.text      "dcterms_publisher",     default: [],    null: false, array: true
    t.text      "dcterms_access_right",  default: [],    null: false, array: true
    t.text      "dcterms_rights_holder", default: [],    null: false, array: true
    t.text      "dcterms_subject",       default: [],    null: false, array: true
    t.text      "dcterms_temporal",      default: [],    null: false, array: true
    t.text      "dcterms_title",         default: [],    null: false, array: true
    t.text      "dcterms_type",          default: [],    null: false, array: true
    t.text      "dcterms_is_shown_at",   default: [],    null: false, array: true
    t.text      "dcterms_provenance",    default: [],    null: false, array: true
    t.text      "dcterms_license",       default: [],    null: false, array: true
    t.integer   "items_count",           default: 0
  end

  add_index "collections", ["repository_id"], name: "index_collections_on_repository_id", using: :btree
  add_index "collections", ["slug"], name: "index_collections_on_slug", using: :btree

  create_table "collections_subjects", id: false, force: :cascade do |t|
    t.integer "collection_id", null: false
    t.integer "subject_id",    null: false
  end

  add_index "collections_subjects", ["collection_id", "subject_id"], name: "index_collections_subjects_on_collection_id_and_subject_id", using: :btree
  add_index "collections_subjects", ["subject_id", "collection_id"], name: "index_collections_subjects_on_subject_id_and_collection_id", using: :btree

  create_table "collections_users", id: false, force: :cascade do |t|
    t.integer "collection_id", null: false
    t.integer "user_id",       null: false
  end

  add_index "collections_users", ["collection_id", "user_id"], name: "index_collections_users_on_collection_id_and_user_id", using: :btree
  add_index "collections_users", ["user_id", "collection_id"], name: "index_collections_users_on_user_id_and_collection_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "items", force: :cascade do |t|
    t.integer  "collection_id"
    t.boolean  "dpla",                  default: false, null: false
    t.boolean  "public",                default: false, null: false
    t.text     "dc_format",             default: [],    null: false, array: true
    t.text     "dc_identifier",         default: [],    null: false, array: true
    t.text     "dc_right",              default: [],    null: false, array: true
    t.text     "dc_date",               default: [],    null: false, array: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.text     "dc_relation",           default: [],    null: false, array: true
    t.string   "other_collections",     default: [],                 array: true
    t.string   "slug",                                  null: false
    t.text     "dcterms_is_part_of",    default: [],    null: false, array: true
    t.text     "dcterms_contributor",   default: [],    null: false, array: true
    t.text     "dcterms_creator",       default: [],    null: false, array: true
    t.text     "dcterms_description",   default: [],    null: false, array: true
    t.text     "dcterms_extent",        default: [],    null: false, array: true
    t.text     "dcterms_medium",        default: [],    null: false, array: true
    t.text     "dcterms_identifier",    default: [],    null: false, array: true
    t.text     "dcterms_language",      default: [],    null: false, array: true
    t.text     "dcterms_spatial",       default: [],    null: false, array: true
    t.text     "dcterms_publisher",     default: [],    null: false, array: true
    t.text     "dcterms_access_right",  default: [],    null: false, array: true
    t.text     "dcterms_rights_holder", default: [],    null: false, array: true
    t.text     "dcterms_subject",       default: [],    null: false, array: true
    t.text     "dcterms_temporal",      default: [],    null: false, array: true
    t.text     "dcterms_title",         default: [],    null: false, array: true
    t.text     "dcterms_type",          default: [],    null: false, array: true
    t.text     "dcterms_is_shown_at",   default: [],    null: false, array: true
    t.text     "dcterms_provenance",    default: [],    null: false, array: true
    t.text     "dcterms_license",       default: [],    null: false, array: true
  end

  add_index "items", ["collection_id"], name: "index_items_on_collection_id", using: :btree
  add_index "items", ["dpla"], name: "index_items_on_dpla", using: :btree
  add_index "items", ["public"], name: "index_items_on_public", using: :btree
  add_index "items", ["slug"], name: "index_items_on_slug", using: :btree

  create_table "permissions", force: :cascade do |t|
    t.string   "action"
    t.string   "class_name", null: false
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "repositories", force: :cascade do |t|
    t.string   "slug",                              null: false
    t.boolean  "public",            default: false, null: false
    t.boolean  "in_georgia",        default: true,  null: false
    t.string   "title",                             null: false
    t.string   "color"
    t.string   "homepage_url"
    t.string   "directions_url"
    t.text     "teaser"
    t.text     "short_description"
    t.text     "description"
    t.text     "address"
    t.text     "strengths"
    t.text     "contact"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "dpla",              default: false, null: false
    t.integer  "collections_count", default: 0
  end

  add_index "repositories", ["slug"], name: "index_repositories_on_slug", unique: true, using: :btree

  create_table "repositories_users", id: false, force: :cascade do |t|
    t.integer "repository_id", null: false
    t.integer "user_id",       null: false
  end

  add_index "repositories_users", ["repository_id", "user_id"], name: "index_repositories_users_on_repository_id_and_user_id", using: :btree
  add_index "repositories_users", ["user_id", "repository_id"], name: "index_repositories_users_on_user_id_and_repository_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "role_id", null: false
    t.integer "user_id", null: false
  end

  add_index "roles_users", ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", using: :btree
  add_index "roles_users", ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id", using: :btree

  create_table "searches", force: :cascade do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.string   "user_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id", using: :btree

  create_table "subjects", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "guest",                  default: false
    t.integer  "creator_id"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
    t.integer  "failed_attempts",        default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "users", ["creator_id"], name: "index_users_on_creator_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "batch_items", "batches"
  add_foreign_key "batch_items", "collections"
  add_foreign_key "collections", "repositories"
  add_foreign_key "items", "collections"
end
