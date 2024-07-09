// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
//= require activestorage

import '@hotwired/turbo-rails';
import 'controllers';

Turbo.setConfirmMethod((message, element) => {
  let dialog = document.getElementById('turbo-confirm');

  dialog.querySelector('p').textContent = message;
  dialog.showModal();

  return new Promise((resolve, reject) => {
    dialog.addEventListener('close', () => {
      resolve(dialog.returnValue == 'confirm');
    }, { once: true });
  });
});

document.addEventListener('turbo:before-stream-render', (event) => {
  const action = event.target.action;
  const className = `turbo-${action}`;

  if (action === 'remove') {
    const targetFrame = document.getElementById(event.target.target);

    event.preventDefault();

    const elementBeingAnimated = targetFrame;

    elementBeingAnimated.addEventListener('animationend', () => {
      targetFrame.remove();
    }, { once: true });

    elementBeingAnimated.classList.add(className);
  } else if (action === 'prepend' || action === 'replace') {
    const targetTemplate = event.target.templateElement.content.firstElementChild;

    if (!targetTemplate.dataset.controller) {
      targetTemplate.dataset.controller = 'removals';
      targetTemplate.dataset.action = 'animationend->removals#removeClass:once';
      targetTemplate.dataset.class = className;
      targetTemplate.classList.add(className);
    }
  } else if (action === 'update') {
    const targetFrame = document.getElementById(event.target.target);

    if (targetFrame.classList.length === 0) {
      targetFrame.dataset.controller = 'removals';
      targetFrame.dataset.action = 'animationend->removals#removeClass';
      targetFrame.dataset.class = className;
      targetFrame.classList.add(className);
    }
  }
})

document.addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event
  const { id, file } = detail

  target.insertAdjacentHTML("beforebegin", `
    <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
      <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
      <span class="direct-upload__filename"></span>
    </div>
  `)
  target.previousElementSibling.querySelector(`.direct-upload__filename`).textContent = file.name
})

document.addEventListener("direct-upload:start", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.remove("direct-upload--pending")
})

document.addEventListener("direct-upload:progress", event => {
  const { id, progress } = event.detail
  const progressElement = document.getElementById(`direct-upload-progress-${id}`)
  progressElement.style.width = `${progress}%`
})

document.addEventListener("direct-upload:error", event => {
  event.preventDefault()
  const { id, error } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--error")
  element.setAttribute("title", error)
})

document.addEventListener("direct-upload:end", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--complete")
})
