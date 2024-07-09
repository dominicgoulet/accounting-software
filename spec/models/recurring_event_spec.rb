# frozen_string_literal: true

# == Schema Information
#
# Table name: recurring_events
#
#  id              :uuid             not null, primary key
#  day_of_month    :integer          default([]), is an Array
#  day_of_week     :integer          default([]), is an Array
#  day_of_year     :integer          default([]), is an Array
#  end_repeat      :string
#  frequency       :string
#  interval        :integer
#  month_of_year   :integer          default([]), is an Array
#  recurrable_type :string
#  repeat_count    :integer
#  repeat_until    :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  recurrable_id   :uuid
#
require 'rails_helper'

RSpec.describe RecurringEvent do
  context 'has a valid factory' do
    let(:recurring_event) { FactoryBot.build(:recurring_event) }

    it { expect(recurring_event).to be_valid }
  end

  context 'associations' do
    let(:recurring_event) { FactoryBot.build(:recurring_event) }

    it { expect(recurring_event).to belong_to(:organization) }
    it { expect(recurring_event).to belong_to(:recurrable) }
  end

  context 'validations' do
    let(:recurring_event) { FactoryBot.build(:recurring_event) }

    it { expect(recurring_event).to validate_presence_of(:organization) }
    it { expect(recurring_event).to validate_presence_of(:frequency) }

    it {
      expect(recurring_event).to enumerize(:frequency).in(:daily, :weekly, :monthly, :yearly).with_default(:monthly)
    }
    it { expect(recurring_event).to enumerize(:end_repeat).in(:never, :count, :date).with_default(:never) }
  end

  context 'callbacks' do
    let(:recurring_event) { FactoryBot.build(:recurring_event) }

    it { expect(recurring_event).to callback(:can_update?).before(:update) }
    it { expect(recurring_event).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:recurring_event) { FactoryBot.create(:recurring_event) }
      before(:each) { recurring_event.update(updated_at: DateTime.now.zone) }

      it { expect(recurring_event.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:recurring_event) { FactoryBot.create(:recurring_event) }
      before(:each) { recurring_event.destroy }

      it { expect(recurring_event.errors.size).to eq(0) }
    end
  end
end
