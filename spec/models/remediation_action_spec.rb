# frozen_string_literal: true

require 'rails_helper'

describe RemediationAction do
  it 'has none to begin with' do
    expect(RemediationAction.count).to eq 0
  end
  context 'basic attributes' do
    let(:remediation_action) { Fabricate :remediation_action }
    it 'has a basic fields' do
      expect(remediation_action.field).not_to be_empty
      expect(remediation_action.old_text).not_to be_empty
      expect(remediation_action.new_text).not_to be_empty
    end
    it 'has a User relation' do
      expect(remediation_action.user).to be_a User
    end
  end
  context 'validations' do
    it 'requires a field value' do
      action = Fabricate.build :remediation_action, field: nil
      action.valid?
      expect(action.errors).to have_key :field
    end
    it 'requires a old_text value' do
      action = Fabricate.build :remediation_action, old_text: nil
      action.valid?
      expect(action.errors).to have_key :old_text
    end
    it 'requires a new_text value' do
      action = Fabricate.build :remediation_action, new_text: nil
      action.valid?
      expect(action.errors).to have_key :new_text
    end
  end
end
