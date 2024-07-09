# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_document_line_taxes
#
#  id                          :uuid             not null, primary key
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  commercial_document_line_id :uuid
#  sales_tax_id                :uuid
#
require 'rails_helper'

RSpec.describe CommercialDocumentLineTax do
  context 'has a valid factory' do
    let(:commercial_document_line_tax) { FactoryBot.build(:commercial_document_line_tax) }

    it { expect(commercial_document_line_tax).to be_valid }
  end

  context 'associations' do
    let(:commercial_document_line_tax) { FactoryBot.build(:commercial_document_line_tax) }

    it { expect(commercial_document_line_tax).to belong_to(:line) }
    it { expect(commercial_document_line_tax).to belong_to(:sales_tax) }
  end

  context 'validations' do
    let(:commercial_document_line_tax) { FactoryBot.build(:commercial_document_line_tax) }

    it { expect(commercial_document_line_tax).to validate_presence_of(:line) }
    it { expect(commercial_document_line_tax).to validate_presence_of(:sales_tax) }
  end

  context 'callbacks' do
    let(:commercial_document_line_tax) { FactoryBot.build(:commercial_document_line_tax) }

    it { expect(commercial_document_line_tax).to callback(:can_update?).before(:update) }
    it { expect(commercial_document_line_tax).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:commercial_document_line_tax) { FactoryBot.create(:commercial_document_line_tax) }
      before(:each) { commercial_document_line_tax.update(updated_at: DateTime.now.zone) }

      it { expect(commercial_document_line_tax.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:commercial_document_line_tax) { FactoryBot.create(:commercial_document_line_tax) }
      before(:each) { commercial_document_line_tax.destroy }

      it { expect(commercial_document_line_tax.errors.size).to eq(0) }
    end
  end
end
