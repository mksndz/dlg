class ItemVersion < PaperTrail::Version
  include IndexFilterable

  self.table_name = :item_versions
  self.sequence_name = :item_versions_id_seq

  default_scope { where.not(event: 'create')}

  def self.index_query_fields
    %w(whodunnit).freeze
  end

end