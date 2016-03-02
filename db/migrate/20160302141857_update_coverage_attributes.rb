class UpdateCoverageAttributes < ActiveRecord::Migration
  def change

    change_table :items do |t|
      t.rename :dc_coverage_t, :dc_coverage_temporal
      t.rename :dc_coverage_s, :dc_coverage_spatial
    end

    change_table :batch_items do |t|
      t.rename :dc_coverage_t, :dc_coverage_temporal
      t.rename :dc_coverage_s, :dc_coverage_spatial
    end

  end
end
