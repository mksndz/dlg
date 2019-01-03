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

ActiveRecord::Schema.define(version: 20181213185026) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "batch_imports", force: :cascade do |t|
    t.string   "format",                            null: false
    t.integer  "user_id",                           null: false
    t.integer  "batch_id",                          null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.json     "results",           default: {}
    t.boolean  "validations"
    t.integer  "batch_items_count"
    t.datetime "completed_at"
    t.integer  "item_ids",          default: [],    null: false, array: true
    t.string   "xml"
    t.string   "file_name"
    t.boolean  "match_on_id",       default: false, null: false
  end

  create_table "batch_items", force: :cascade do |t|
    t.boolean  "dpla",                           default: false, null: false
    t.boolean  "public",                         default: false, null: false
    t.text     "dc_format",                      default: [],    null: false, array: true
    t.text     "dc_right",                       default: [],    null: false, array: true
    t.text     "dc_date",                        default: [],    null: false, array: true
    t.text     "dc_relation",                    default: [],    null: false, array: true
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "batch_id",                                       null: false
    t.integer  "collection_id"
    t.string   "slug",                                           null: false
    t.text     "dcterms_is_part_of",             default: [],    null: false, array: true
    t.text     "dcterms_contributor",            default: [],    null: false, array: true
    t.text     "dcterms_creator",                default: [],    null: false, array: true
    t.text     "dcterms_description",            default: [],    null: false, array: true
    t.text     "dcterms_extent",                 default: [],    null: false, array: true
    t.text     "dcterms_medium",                 default: [],    null: false, array: true
    t.text     "dcterms_identifier",             default: [],    null: false, array: true
    t.text     "dcterms_language",               default: [],    null: false, array: true
    t.text     "dcterms_spatial",                default: [],    null: false, array: true
    t.text     "dcterms_publisher",              default: [],    null: false, array: true
    t.text     "dcterms_rights_holder",          default: [],    null: false, array: true
    t.text     "dcterms_subject",                default: [],    null: false, array: true
    t.text     "dcterms_temporal",               default: [],    null: false, array: true
    t.text     "dcterms_title",                  default: [],    null: false, array: true
    t.text     "dcterms_type",                   default: [],    null: false, array: true
    t.text     "edm_is_shown_at",                default: [],    null: false, array: true
    t.text     "legacy_dcterms_provenance",      default: [],    null: false, array: true
    t.integer  "item_id"
    t.integer  "other_collections",              default: [],                 array: true
    t.text     "dlg_local_right",                default: [],    null: false, array: true
    t.boolean  "valid_item",                     default: false, null: false
    t.boolean  "has_thumbnail",                  default: false, null: false
    t.text     "dcterms_bibliographic_citation", default: [],    null: false, array: true
    t.integer  "batch_import_id"
    t.boolean  "local",                          default: false, null: false
    t.text     "dlg_subject_personal",           default: [],    null: false, array: true
    t.string   "record_id",                      default: "",    null: false
    t.text     "edm_is_shown_by",                default: [],    null: false, array: true
    t.text     "fulltext"
  end

  add_index "batch_items", ["batch_id"], name: "index_batch_items_on_batch_id", using: :btree
  add_index "batch_items", ["batch_import_id"], name: "index_batch_items_on_batch_import_id", using: :btree
  add_index "batch_items", ["item_id"], name: "index_batch_items_on_item_id", using: :btree
  add_index "batch_items", ["other_collections"], name: "index_batch_items_on_other_collections", using: :btree
  add_index "batch_items", ["slug"], name: "index_batch_items_on_slug", using: :btree
  add_index "batch_items", ["valid_item"], name: "index_batch_items_on_valid_item", using: :btree

  create_table "batch_items_holding_institutions", id: false, force: :cascade do |t|
    t.integer "holding_institution_id", null: false
    t.integer "batch_item_id",          null: false
  end

  create_table "batches", force: :cascade do |t|
    t.integer  "contained_count"
    t.string   "name",                              null: false
    t.text     "notes"
    t.datetime "committed_at"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "user_id"
    t.json     "commit_results",       default: {}, null: false
    t.integer  "batch_items_count",    default: 0
    t.datetime "queued_for_commit_at"
    t.string   "job_message"
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
    t.text      "display_title",                                  null: false
    t.text      "short_description"
    t.text      "dc_format",                      default: [],    null: false, array: true
    t.text      "dc_right",                       default: [],    null: false, array: true
    t.text      "dc_date",                        default: [],    null: false, array: true
    t.daterange "date_range"
    t.datetime  "created_at",                                     null: false
    t.datetime  "updated_at",                                     null: false
    t.text      "dc_relation",                    default: [],    null: false, array: true
    t.string    "other_repositories",             default: [],                 array: true
    t.boolean   "public",                         default: false, null: false
    t.string    "slug",                                           null: false
    t.text      "dcterms_is_part_of",             default: [],    null: false, array: true
    t.text      "dcterms_contributor",            default: [],    null: false, array: true
    t.text      "dcterms_creator",                default: [],    null: false, array: true
    t.text      "dcterms_description",            default: [],    null: false, array: true
    t.text      "dcterms_extent",                 default: [],    null: false, array: true
    t.text      "dcterms_medium",                 default: [],    null: false, array: true
    t.text      "dcterms_identifier",             default: [],    null: false, array: true
    t.text      "dcterms_language",               default: [],    null: false, array: true
    t.text      "dcterms_spatial",                default: [],    null: false, array: true
    t.text      "dcterms_publisher",              default: [],    null: false, array: true
    t.text      "dcterms_rights_holder",          default: [],    null: false, array: true
    t.text      "dcterms_subject",                default: [],    null: false, array: true
    t.text      "dcterms_temporal",               default: [],    null: false, array: true
    t.text      "dcterms_title",                  default: [],    null: false, array: true
    t.text      "dcterms_type",                   default: [],    null: false, array: true
    t.text      "edm_is_shown_at",                default: [],    null: false, array: true
    t.text      "legacy_dcterms_provenance",      default: [],    null: false, array: true
    t.text      "dcterms_license",                default: [],    null: false, array: true
    t.integer   "items_count",                    default: 0
    t.text      "dcterms_bibliographic_citation", default: [],    null: false, array: true
    t.text      "dlg_local_right",                default: [],    null: false, array: true
    t.text      "dlg_subject_personal",           default: [],    null: false, array: true
    t.string    "record_id",                      default: "",    null: false
    t.text      "edm_is_shown_by",                default: [],    null: false, array: true
    t.string    "partner_homepage_url"
    t.text      "homepage_text"
  end

  add_index "collections", ["repository_id"], name: "index_collections_on_repository_id", using: :btree
  add_index "collections", ["slug"], name: "index_collections_on_slug", using: :btree

  create_table "collections_holding_institutions", id: false, force: :cascade do |t|
    t.integer "holding_institution_id", null: false
    t.integer "collection_id",          null: false
  end

  add_index "collections_holding_institutions", ["collection_id"], name: "idx_coll_hi_on_coll_id", using: :btree
  add_index "collections_holding_institutions", ["holding_institution_id"], name: "idx_coll_hi_on_hi_id", using: :btree

  create_table "collections_projects", id: false, force: :cascade do |t|
    t.integer "project_id",    null: false
    t.integer "collection_id", null: false
  end

  create_table "collections_subjects", id: false, force: :cascade do |t|
    t.integer "collection_id", null: false
    t.integer "subject_id",    null: false
  end

  add_index "collections_subjects", ["collection_id", "subject_id"], name: "index_collections_subjects_on_collection_id_and_subject_id", using: :btree
  add_index "collections_subjects", ["subject_id", "collection_id"], name: "index_collections_subjects_on_subject_id_and_collection_id", using: :btree

  create_table "collections_time_periods", id: false, force: :cascade do |t|
    t.integer "time_period_id", null: false
    t.integer "collection_id",  null: false
  end

  add_index "collections_time_periods", ["collection_id", "time_period_id"], name: "idx_col_time_per_on_coll_and_time_per", using: :btree
  add_index "collections_time_periods", ["time_period_id", "collection_id"], name: "idx_col_time_per_on_time_per_and_coll", using: :btree

  create_table "collections_users", id: false, force: :cascade do |t|
    t.integer "collection_id", null: false
    t.integer "user_id",       null: false
  end

  add_index "collections_users", ["collection_id", "user_id"], name: "index_collections_users_on_collection_id_and_user_id", using: :btree
  add_index "collections_users", ["user_id", "collection_id"], name: "index_collections_users_on_user_id_and_collection_id", using: :btree

  create_table "features", force: :cascade do |t|
    t.string   "title"
    t.string   "title_link"
    t.string   "institution"
    t.string   "institution_link"
    t.string   "short_description"
    t.string   "external_link"
    t.boolean  "primary"
    t.string   "image"
    t.string   "area"
    t.string   "large_image"
    t.boolean  "public",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fulltext_ingests", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "file"
    t.json     "results",     default: {}
    t.integer  "user_id"
    t.datetime "queued_at"
    t.datetime "finished_at"
    t.datetime "undone_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "holding_institutions", force: :cascade do |t|
    t.string   "authorized_name"
    t.text     "short_description"
    t.text     "description"
    t.string   "image"
    t.string   "homepage_url"
    t.string   "coordinates"
    t.text     "strengths"
    t.text     "contact_information"
    t.string   "institution_type"
    t.boolean  "galileo_member"
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "harvest_strategy"
    t.string   "oai_urls",            default: [], array: true
    t.text     "ignored_collections"
    t.datetime "last_harvested_at"
    t.text     "analytics_emails",    default: [], array: true
    t.text     "subgranting"
    t.text     "grant_partnerships"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parent_institution"
    t.text     "notes"
    t.string   "display_name"
  end

  add_index "holding_institutions", ["authorized_name"], name: "index_holding_institutions_on_authorized_name", using: :btree

  create_table "holding_institutions_items", id: false, force: :cascade do |t|
    t.integer "holding_institution_id", null: false
    t.integer "item_id",                null: false
  end

  add_index "holding_institutions_items", ["holding_institution_id"], name: "idx_item_hi_on_hi_id", using: :btree
  add_index "holding_institutions_items", ["item_id"], name: "idx_item_hi_on_item_id", using: :btree

  create_table "holding_institutions_repositories", id: false, force: :cascade do |t|
    t.integer "holding_institution_id", null: false
    t.integer "repository_id",          null: false
  end

  create_table "item_versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.datetime "created_at"
    t.json     "object"
  end

  add_index "item_versions", ["item_type", "item_id"], name: "index_item_versions_on_item_type_and_item_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.integer  "collection_id"
    t.boolean  "dpla",                           default: false, null: false
    t.boolean  "public",                         default: false, null: false
    t.text     "dc_format",                      default: [],    null: false, array: true
    t.text     "dc_right",                       default: [],    null: false, array: true
    t.text     "dc_date",                        default: [],    null: false, array: true
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.text     "dc_relation",                    default: [],    null: false, array: true
    t.string   "slug",                                           null: false
    t.text     "dcterms_is_part_of",             default: [],    null: false, array: true
    t.text     "dcterms_contributor",            default: [],    null: false, array: true
    t.text     "dcterms_creator",                default: [],    null: false, array: true
    t.text     "dcterms_description",            default: [],    null: false, array: true
    t.text     "dcterms_extent",                 default: [],    null: false, array: true
    t.text     "dcterms_medium",                 default: [],    null: false, array: true
    t.text     "dcterms_identifier",             default: [],    null: false, array: true
    t.text     "dcterms_language",               default: [],    null: false, array: true
    t.text     "dcterms_spatial",                default: [],    null: false, array: true
    t.text     "dcterms_publisher",              default: [],    null: false, array: true
    t.text     "dcterms_rights_holder",          default: [],    null: false, array: true
    t.text     "dcterms_subject",                default: [],    null: false, array: true
    t.text     "dcterms_temporal",               default: [],    null: false, array: true
    t.text     "dcterms_title",                  default: [],    null: false, array: true
    t.text     "dcterms_type",                   default: [],    null: false, array: true
    t.text     "edm_is_shown_at",                default: [],    null: false, array: true
    t.text     "legacy_dcterms_provenance",      default: [],    null: false, array: true
    t.integer  "other_collections",              default: [],                 array: true
    t.text     "dlg_local_right",                default: [],    null: false, array: true
    t.boolean  "valid_item",                     default: false, null: false
    t.boolean  "has_thumbnail",                  default: false, null: false
    t.text     "dcterms_bibliographic_citation", default: [],    null: false, array: true
    t.boolean  "local",                          default: false, null: false
    t.text     "dlg_subject_personal",           default: [],    null: false, array: true
    t.string   "record_id",                      default: "",    null: false
    t.text     "edm_is_shown_by",                default: [],    null: false, array: true
    t.text     "fulltext"
    t.integer  "pages_count"
  end

  add_index "items", ["collection_id"], name: "index_items_on_collection_id", using: :btree
  add_index "items", ["dpla"], name: "index_items_on_dpla", using: :btree
  add_index "items", ["other_collections"], name: "index_items_on_other_collections", using: :btree
  add_index "items", ["public"], name: "index_items_on_public", using: :btree
  add_index "items", ["slug"], name: "index_items_on_slug", using: :btree
  add_index "items", ["valid_item"], name: "index_items_on_valid_item", using: :btree

  create_table "pages", force: :cascade do |t|
    t.integer  "item_id"
    t.text     "fulltext"
    t.string   "title"
    t.string   "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "file_type"
  end

  create_table "portal_records", force: :cascade do |t|
    t.integer "portal_id"
    t.integer "portable_id"
    t.string  "portable_type"
  end

  add_index "portal_records", ["portable_type", "portable_id"], name: "index_portal_records_on_portable_type_and_portable_id", using: :btree
  add_index "portal_records", ["portal_id"], name: "index_portal_records_on_portal_id", using: :btree

  create_table "portals", force: :cascade do |t|
    t.string "code"
    t.text   "name"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "title"
    t.string   "fiscal_year"
    t.string   "hosting"
    t.float    "storage_used"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "holding_institution_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.string   "slug",                              null: false
    t.boolean  "public",            default: false, null: false
    t.string   "title",                             null: false
    t.text     "notes"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "collections_count", default: 0
    t.string   "image"
  end

  add_index "repositories", ["slug"], name: "index_repositories_on_slug", unique: true, using: :btree

  create_table "repositories_users", id: false, force: :cascade do |t|
    t.integer "repository_id", null: false
    t.integer "user_id",       null: false
  end

  add_index "repositories_users", ["repository_id", "user_id"], name: "index_repositories_users_on_repository_id_and_user_id", using: :btree
  add_index "repositories_users", ["user_id", "repository_id"], name: "index_repositories_users_on_user_id_and_repository_id", using: :btree

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

  create_table "time_periods", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "span"
    t.integer  "start"
    t.integer  "finish"
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
    t.boolean  "is_super",               default: false, null: false
    t.boolean  "is_coordinator",         default: false, null: false
    t.boolean  "is_committer",           default: false, null: false
    t.boolean  "is_uploader",            default: false, null: false
    t.boolean  "is_viewer",              default: false, null: false
    t.boolean  "is_pm",                  default: false, null: false
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
