# frozen_string_literal: true

class AttachedFilesListComponent < ViewComponent::Base
  def initialize(attached_files)
    super
    @attached_files = attached_files
  end
end
