require 'rails_helper'

describe Reindexer, type: :model do

  describe '#perform' do

    let(:collection) {
      Fabricate :collection
    }
    
    context 'with a reindexable model' do
      
      it 'should not fail' do
        
        expect {
          Reindexer.perform('Collection')
        }.not_to raise_exception
        
      end
      
    end

  end

end