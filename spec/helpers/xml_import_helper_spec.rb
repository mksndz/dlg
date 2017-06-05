require 'rails_helper'

describe XmlImportHelper do

  describe '#prepare_item_hash' do

    context 'with a hash containing nested arrays' do

      let :nested_array_hash do
        {
          dcterms_creator: ['WSB-TV (Television station : Atlanta, Ga.)'],
          dcterms_subject: ['Presidents--United States--Election--1960', 'International relations', 'Elections'],
          dcterms_spatial: [['Cuba'], ['United States']],
          dcterms_temporal: [['1960'], ['1960']],
          dc_date: [[['1960']], ['1960']],
          dlg_subject_personal: ['UNDERWOOD, NORMAN', 'Kennedy, John F. (John Fitzgerald), 1917-1963', 'Nixon, Richard M. (Richard Milhous), 1913-1994'],
          local: true
        }
      end

      it 'should flatten the arrays and remove duplicate values' do

        expect(nested_array_hash).to be_a Hash

        prepared_hash = prepare_item_hash nested_array_hash

        # array elements are flattened
        expect(prepared_hash[:dcterms_creator].first).not_to be_a_kind_of Array
        expect(prepared_hash[:dc_date].first).not_to be_a_kind_of Array
        expect(prepared_hash[:dcterms_temporal].first).not_to be_a_kind_of Array
        expect(prepared_hash[:dcterms_spatial].first).not_to be_a_kind_of Array
        expect(prepared_hash[:local]).to be_truthy

        # remove duplicates in array elements
        expect(prepared_hash[:dc_date]).to eq ['1960']
        expect(prepared_hash[:dcterms_temporal]).to eq ['1960']
        expect(prepared_hash[:dcterms_spatial]).to eq ['Cuba', 'United States']

      end

    end

  end

end