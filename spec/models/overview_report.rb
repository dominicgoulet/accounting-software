require 'rails_helper'

RSpec.describe OverviewReport do
  context 'initialize properly' do
    let(:organization) { FactoryBot.create(:organization) }

    it { expect(OverviewReport.new(organization.id)).to be_valid }
    it { expect(OverviewReport.new(organization.id).execute).to be_valid }
  end
end
