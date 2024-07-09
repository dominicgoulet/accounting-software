# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModalComponent do
  context 'has a valid constructor' do
    let(:component) { ModalComponent.new }

    it { expect(component).not_to be_nil }
  end
end
