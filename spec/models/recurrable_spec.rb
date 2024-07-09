# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recurrable do
  context 'has a valid factory' do
    let(:recurrable) { FactoryBot.build(:journal_entry) }

    it { expect(recurrable).to be_valid }
  end

  context 'associations' do
    let(:recurrable) { FactoryBot.build(:journal_entry) }

    it { expect(recurrable).to have_one(:recurring_event) }
  end

  context 'methods' do
    context '.setup_recurring_event!' do
      context 'when enabling' do
        let(:recurrable) { FactoryBot.create(:journal_entry) }

        it { expect(recurrable.recurring_event).to be_nil }
        it {
          expect do
            recurrable.setup_recurring_event!(true, { frequency: :monthly })
          end.to change(RecurringEvent, :count)
        }

        context 'after enabling' do
          before(:each) { recurrable.setup_recurring_event!(true, { frequency: :monthly }) }

          it { expect(recurrable.recurring_event).not_to be_nil }
        end
      end

      context 'when enabling then updating' do
        let(:recurrable) { FactoryBot.create(:journal_entry) }
        before(:each) { recurrable.setup_recurring_event!(true, { frequency: :monthly }) }

        it { expect(recurrable.recurring_event).not_to be_nil }
        it {
          expect do
            recurrable.setup_recurring_event!(true, { frequency: :monthly })
          end.not_to change(RecurringEvent, :count)
        }
      end

      context 'when enabling then disabling' do
        let(:recurrable) { FactoryBot.create(:journal_entry) }
        before(:each) { recurrable.setup_recurring_event!(true, { frequency: :monthly }) }

        it { expect(recurrable.recurring_event).not_to be_nil }
        it {
          expect do
            recurrable.setup_recurring_event!(false, { frequency: :monthly })
          end.to change(RecurringEvent, :count)
        }
      end

      context 'when disabling and not already enabled' do
        let(:recurrable) { FactoryBot.create(:journal_entry) }

        it { expect(recurrable.recurring_event).to be_nil }
        it {
          expect do
            recurrable.setup_recurring_event!(false, { frequency: :monthly })
          end.not_to change(RecurringEvent, :count)
        }

        context 'after disabling' do
          before(:each) { recurrable.setup_recurring_event!(false, { frequency: :monthly }) }

          it { expect(recurrable.recurring_event).to be_nil }
        end
      end
    end
  end
end
