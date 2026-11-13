'use strict';

const form = document.querySelector('#contact');
const button = form.querySelector('button');
const status = document.querySelector('#status');
const nameField = form.elements.namedItem('name');
const messageField = form.elements.namedItem('message');
const endpoint = form.getAttribute('action') ?? '';
const canSend = /^https:\/\/formspree\.io\/f\/[a-z0-9]+$/i.test(endpoint);

function showStatus(text, isError = false) {
  status.textContent = text;
  status.toggleAttribute('data-error', isError);
}

if (canSend) {
  button.disabled = false;
} else {
  showStatus('The form isn’t accepting messages yet. Please use the email link below.');
}

for (const field of [nameField, messageField]) {
  field.addEventListener('input', () => field.setCustomValidity(''));
}

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  if (!canSend || button.disabled) return;

  nameField.setCustomValidity(nameField.value.trim() ? '' : 'Enter your name.');
  messageField.setCustomValidity(messageField.value.trim() ? '' : 'Enter a message.');
  if (!form.reportValidity()) return;

  const body = new FormData(form);
  body.set('name', nameField.value.trim());
  body.set('message', messageField.value.trim());
  button.disabled = true;
  showStatus('Sending your message…');

  try {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: { Accept: 'application/json' },
      body,
      signal: AbortSignal.timeout(15000),
    });
    if (response.ok) {
      form.reset();
      showStatus('Message sent. Thanks for reaching out!');
    } else if (response.status === 429) {
      showStatus('Too many attempts. Wait a minute and try again, or email me directly.', true);
    } else {
      showStatus('Your message couldn’t be sent. Try again or email me directly.', true);
    }
  } catch {
    showStatus('Delivery couldn’t be confirmed. Please wait before trying again, or email me directly.', true);
  } finally {
    button.disabled = false;
  }
});
