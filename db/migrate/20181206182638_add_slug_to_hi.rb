# Adds a slug field for Holding Institution records
class AddSlugToHi < ActiveRecord::Migration
  def change
    add_column :holding_institutions, :slug, :string

    HoldingInstitution.all.each do |hi|
      next unless hi.repositories.any?

      hi.slug = hi.repositories.first.slug
      hi.save
    end
  end
end
