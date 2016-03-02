class UpdateCoverageAttributesOnColl < ActiveRecord::Migration
  def change
    change_table :collections do |t|
      t.rename :dc_coverage_t, :dc_coverage_temporal
      t.rename :dc_coverage_s, :dc_coverage_spatial
    end
  end
end
