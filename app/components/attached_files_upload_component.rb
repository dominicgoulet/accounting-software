# frozen_string_literal: true

class AttachedFilesUploadComponent < ViewComponent::Base
  def initialize(form:)
    super
    @form = form
  end
end
