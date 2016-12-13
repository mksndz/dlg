require 'faker'

Fabricator :portal do

  name { Faker::Hipster.sentence(3) }
  code { Faker::Hipster.word.downcase }

end