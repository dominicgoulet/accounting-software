# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttachedFilesUploadComponent do
  context 'has a valid constructor' do
    let(:component) { AttachedFilesUploadComponent.new(form: nil) }

    it { expect(component).not_to be_nil }
  end
end
