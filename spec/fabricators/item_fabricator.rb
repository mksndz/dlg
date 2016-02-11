require 'faker'

Fabricator(:item) do

  slug { Faker::Internet.slug(Faker::Lorem.sentence(3).chomp('.'),'-') }
  dc_title { [
      Faker::Lorem.sentence(5),
      Faker::Lorem.sentence(4)
  ] }
  dc_format { [
      %w(StillImage Text).sample
  ]}
  dc_subject { [
      %w(Athens Atlanta Augusta Macon).sample,
      'Georgia'
  ]}

end