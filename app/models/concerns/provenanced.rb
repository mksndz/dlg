# behaviors for models that have a provenance (Holding Institution)
module Provenanced
  extend ActiveSupport::Concern
  included do
    has_and_belongs_to_many(
      :holding_institutions,
      dependent: :restrict_with_error
    )
    validates_presence_of :holding_institutions
  end

  def holding_institution_names
    holding_institutions.collect(&:display_name)
  end

end