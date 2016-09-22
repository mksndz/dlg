require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Maps', js: true do

  before :each do
    login_as Fabricate(:super), scope: :user
  end

  context 'Collection indexing and rendering' do

    before :each do

      Fabricate(:collection)
      Sunspot.commit

      visit map_path

    end

    scenario 'display collection locations on the map' do

      expect(page).to have_selector('div.marker-cluster', count: 1)
      expect(page).to have_selector('.mapped-count .badge', text: '1')


    end

  end

  context 'Item single-valued location indexing and rendering' do

    before :each do

      Fabricate :item
      Sunspot.commit

      visit map_path

      0.upto(2) { find('a.leaflet-control-zoom-in').click } # zoom in a bit

    end

    scenario 'display item and collection location on the map' do

      expect(page).to have_selector('div.marker-cluster', count: 2)
      expect(page).to have_selector('.mapped-count .badge', text: '2')


    end

  end

  context 'Item multi-valued location indexing and rendering' do

    before :each do

      Fabricate :item_with_two_spatial_values
      Sunspot.commit

      visit map_path

      0.upto(3) { find('a.leaflet-control-zoom-in').click } # zoom in a bit

    end

    scenario 'display collection and multiple item locations on the map' do

      expect(page).to have_selector('div.marker-cluster', count: 3)
      expect(page).to have_selector('.mapped-count .badge', text: '3')

    end

  end


end