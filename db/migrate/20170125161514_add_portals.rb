class AddPortals < ActiveRecord::Migration
  def change

       Portal.create!({ name: 'The Digital Library of Georgia', code: 'georgia' }) unless Portal.find_by_code 'georgia'
       Portal.create!({ name: 'The Civil War in the American South', code: 'amso' }) unless Portal.find_by_code 'amso'
       Portal.create!({ name: 'The Civil Rights Digital Library', code: 'crdl' }) unless Portal.find_by_code 'crdl'
       Portal.create!({ name: 'Other', code: 'other' }) unless Portal.find_by_code 'other'

  end
end
