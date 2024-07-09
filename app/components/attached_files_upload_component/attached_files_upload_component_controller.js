import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['fileUploadField', 'filesToUploadList'];

  connect() {
    const input = this.fileUploadFieldTarget;

    input.addEventListener('change', (event) => {
      let html = '';
      let files = Array.from(input.files);

      if (files.length > 0) {
        files.forEach(file => {
          html += `<span class="flex items-center gap-2"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3 h-3"><path fill-rule="evenodd" d="M15.621 4.379a3 3 0 00-4.242 0l-7 7a3 3 0 004.241 4.243h.001l.497-.5a.75.75 0 011.064 1.057l-.498.501-.002.002a4.5 4.5 0 01-6.364-6.364l7-7a4.5 4.5 0 016.368 6.36l-3.455 3.553A2.625 2.625 0 119.52 9.52l3.45-3.451a.75.75 0 111.061 1.06l-3.45 3.451a1.125 1.125 0 001.587 1.595l3.454-3.553a3 3 0 000-4.242z" clip-rule="evenodd"></path></svg>${file.name}</span>`;
        });

        this.filesToUploadListTarget.classList.remove('hidden');
      } else {
        this.filesToUploadListTarget.classList.add('hidden');
      }

      this.filesToUploadListTarget.innerHTML = html;
    })
  }
}
