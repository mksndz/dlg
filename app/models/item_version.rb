class ItemVersion < PaperTrail::Version
  self.table_name = :item_versions
  self.sequence_name = :item_versions_id_seq
  default_scope { where.not(event: 'create')}
end