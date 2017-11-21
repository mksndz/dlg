require 'faker'

Fabricator :batch_item do
  batch
  slug do
    Faker::Internet.slug(
      Faker::Lorem.sentence(3).chomp('.'),
      '-'
    )
  end
  collection { Fabricate :empty_collection }
  portals do |attrs|
    attrs[:collection].portals
  end
  dcterms_title do
    [Faker::Lorem.sentence(5), Faker::Lorem.sentence(4)]
  end
  dcterms_type { [%w(StillImage Text).sample] }
  dcterms_subject { [%w(Athens Atlanta Augusta Macon).sample, 'Georgia'] }
  dc_date ['1999-2000']
  dc_right [I18n.t('meta.rights.zero.uri')]
  dcterms_contributor ['DLG']
  dcterms_spatial { [%w(Athens Atlanta Augusta Macon).sample] }
  dcterms_provenance ['DLG']
  edm_is_shown_at ['http://dlg.galileo.usg.edu']
  edm_is_shown_by ['http://dlg.galileo.usg.edu']
end

Fabricator :batch_item_without_batch, from: :batch_item do
  batch nil
end
