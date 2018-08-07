require 'faker'

Fabricator(:item) do
  slug do
    Faker::Internet.slug(
      Faker::Lorem.sentence(3).chomp('.'),
      '-')
  end
  dcterms_title do
    [
      Faker::Lorem.sentence(5),
      Faker::Lorem.sentence(4)
    ]
  end
  dcterms_type { [%w(StillImage Text).sample] }
  dcterms_subject do
    [
      %w(Athens Atlanta Augusta Macon).sample,
      'Georgia'
    ]
  end
  dc_date ['1999-2000']
  dc_right [I18n.t('meta.rights.zero.uri')]
  dcterms_contributor ['DLG']
  dcterms_spatial [
    'United States, Georgia, Clarke County, Athens, 33.960948, -83.3779358'
  ]
  dcterms_provenance ['DLG']
  edm_is_shown_at ['http://dlg.galileo.usg.edu']
  edm_is_shown_by ['http://dlg.galileo.usg.edu']
  fulltext { Faker::Hipster.paragraph(1) }
end

Fabricator(:item_with_parents, from: :item) do
  repository(fabricator: :empty_repository)
  collection do |attrs|
    Fabricate.build(
      :empty_collection,
      portals: attrs[:repository].portals
    )
  end
  portals do |attrs|
    attrs[:repository].portals
  end
end

Fabricator(:invalid_item) do
  slug do
    Faker::Internet.slug(
      Faker::Lorem.sentence(3).chomp('.'),
      '-')
  end
  dcterms_title do
    [
      Faker::Lorem.sentence(5),
      Faker::Lorem.sentence(4)
    ]
  end
end

Fabricator(:robust_item, from: :item) do
  dcterms_publisher { [Faker::University.name] }
  edm_is_shown_at { [Faker::Internet.url] }
  edm_is_shown_by { [Faker::Internet.url] }
  dcterms_identifier { [Faker::Internet.url] }
  dlg_subject_personal { [Faker::Name.name_with_middle] }
  dcterms_spatial [
    'United States, Georgia, Clarke County, Athens, 33.960948, -83.3779358',
    'United States, Georgia, Fulton County, 33.7902836, -84.466986'
  ]
end