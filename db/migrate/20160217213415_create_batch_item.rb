class CreateBatchItem < ActiveRecord::Migration
  def change

    change_table :items do |t|
      t.remove :type
      t.remove :batch_id
    end

    create_table :batch_items do |t|
      t.string   'slug',                              null: false
      t.boolean  'dpla',              default: false, null: false
      t.boolean  'public',            default: false, null: false
      t.integer  'other_collections', default: [],    null: false, array: true
      t.text     'dc_title',          default: [],    null: false, array: true
      t.text     'dc_format',         default: [],    null: false, array: true
      t.text     'dc_publisher',      default: [],    null: false, array: true
      t.text     'dc_identifier',     default: [],    null: false, array: true
      t.text     'dc_rights',         default: [],    null: false, array: true
      t.text     'dc_contributor',    default: [],    null: false, array: true
      t.text     'dc_coverage_t',     default: [],    null: false, array: true
      t.text     'dc_coverage_s',     default: [],    null: false, array: true
      t.text     'dc_date',           default: [],    null: false, array: true
      t.text     'dc_source',         default: [],    null: false, array: true
      t.text     'dc_subject',        default: [],    null: false, array: true
      t.text     'dc_type',           default: [],    null: false, array: true
      t.text     'dc_description',    default: [],    null: false, array: true
      t.text     'dc_creator',        default: [],    null: false, array: true
      t.text     'dc_language',       default: [],    null: false, array: true
      t.text     'dc_relation',       default: [],    null: false, array: true
      t.datetime 'created_at',                        null: false
      t.datetime 'updated_at',                        null: false
      t.references :batch,      null: false, index: true, foreign_key: true
      t.references :collection, null: false,              foreign_key: true
    end


  end
end
