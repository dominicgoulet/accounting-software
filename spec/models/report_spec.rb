require 'rails_helper'

RSpec.describe Report do
  context 'initialize properly' do
    let(:organization) { FactoryBot.create(:organization) }

    it { expect(Report.new(organization.id)).to be_truthy }
  end
end
