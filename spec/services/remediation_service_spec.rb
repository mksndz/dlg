# frozen_string_literal: true

require 'rails_helper'

describe RemediationService, type: :model do
  let(:service) { RemediationService }
  before :each do
    @items = Fabricate.times 2, :item_with_parents,
                             dcterms_subject: ['Remediate Me']
    @action = Fabricate :remediation_action,
                        field: 'dcterms_subject',
                        old_text: 'Remediate Me',
                        new_text: 'Miracle'
  end
  describe '#prepare' do
    it 'sets the IDs for the items to update' do
      service.prepare(@action)
      expect(@action.items).to eq @items.collect(&:id)
    end
  end
  describe '#run' do
    it 'sets the IDs for the items to update' do
      service.prepare(@action)
      service.run(@action)
      expect(Item.last.dcterms_subject).to eq ['Miracle']
    end
  end
end
