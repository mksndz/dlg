# represent a Project
class Project < ActiveRecord::Base
  include IndexFilterable

  belongs_to :holding_institution
  has_and_belongs_to_many :collections

  validates_presence_of :title, :holding_institution

  def self.index_query_fields
    %w[fiscal_year holding_institution_id]
  end

  def self.fiscal_years
    uniq.pluck :fiscal_year
  end
end
