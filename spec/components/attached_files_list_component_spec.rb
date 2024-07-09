# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttachedFilesListComponent do
  context 'has a valid constructor' do
    let(:component) { AttachedFilesListComponent.new([]) }

    it { expect(component).not_to be_nil }
  end
end
