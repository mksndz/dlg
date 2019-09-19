# frozen_string_literal: true

# a featured thing for the public DLG site
class Feature < ActiveRecord::Base
  scope :random, -> { order('RANDOM()') }
  scope :ordered, -> { order(primary: :desc) }
  scope :carousel, -> { ordered.where(area: 'carousel', public: true) }
  scope :tabs, -> { ordered.where(area: 'tabs', public: true).order(created_at: :desc) }

  mount_uploader :image, ImageUploader
  mount_uploader :large_image, ImageUploader

  validates :title, :title_link, presence: true
  validates :institution, :institution_link, presence: true
  validates :image, presence: true, unless: :primary_tab?
  validates :large_image, presence: true, if: :primary_tab?
  validates :short_description, presence: true, if: :tab?

  def self.available_areas
    %w[carousel tabs]
  end

  def to_json
    super(options.merge!(except: :id))
  end

  def tab?
    area == 'tabs'
  end

  def carousel?
    area == 'carousel'
  end

  def primary_tab?
    primary && tab?
  end
end