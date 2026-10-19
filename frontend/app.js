const requestList = document.getElementById('request-list');
const requestForm = document.getElementById('request-form');
const formStatus = document.getElementById('form-status');
const submitButton = document.getElementById('submit-button');

async function loadRequests() {
    requestList.replaceChildren(makeMessage('Loading requests…'));

    try {
        const response = await fetch('/api/get_requests.php');
        const result = await response.json();

        if (!response.ok || !result.success) {
            throw new Error(result.error || 'Could not load requests.');
        }

        if (result.requests.length === 0) {
            requestList.replaceChildren(makeMessage('No requests yet. Submit the first one.'));
            return;
        }

        const cards = result.requests.map(makeRequestCard);
        requestList.replaceChildren(...cards);
    } catch (error) {
        requestList.replaceChildren(makeMessage('Requests are temporarily unavailable. Please refresh in a moment.', 'error-state'));
        console.error(error);
    }
}

function makeRequestCard(request) {
    const card = document.createElement('article');
    card.className = 'request-card';

    const topRow = document.createElement('div');
    topRow.className = 'request-top-row';

    const category = document.createElement('span');
    category.className = 'category-tag';
    category.textContent = request.category;

    const status = document.createElement('span');
    status.className = 'status-tag';
    status.textContent = request.status;

    topRow.append(category, status);

    const title = document.createElement('h3');
    title.textContent = request.title;

    const details = document.createElement('p');
    details.className = 'request-description';
    details.textContent = request.description;

    const date = document.createElement('p');
    date.className = 'request-date';
    date.textContent = `Submitted ${formatDate(request.created_at)}`;

    card.append(topRow, title, details, date);
    return card;
}

function makeMessage(text, className = 'empty-state') {
    const message = document.createElement('p');
    message.className = className;
    message.textContent = text;
    return message;
}

function formatDate(value) {
    const date = new Date(`${value.replace(' ', 'T')}Z`);
    if (Number.isNaN(date.getTime())) return value;
    return new Intl.DateTimeFormat(undefined, {
        dateStyle: 'medium',
        timeStyle: 'short'
    }).format(date);
}

requestForm.addEventListener('submit', async (event) => {
    event.preventDefault();
    formStatus.textContent = '';
    submitButton.disabled = true;
    submitButton.textContent = 'Submitting…';

    const formData = new FormData(requestForm);
    const payload = Object.fromEntries(formData.entries());

    try {
        const response = await fetch('/api/save_request.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        const result = await response.json();

        if (!response.ok || !result.success) {
            throw new Error(result.error || 'Could not submit the request.');
        }

        requestForm.reset();
        formStatus.textContent = 'Your request was submitted.';
        await loadRequests();
    } catch (error) {
        formStatus.textContent = error.message || 'Request submission failed. Please try again.';
        console.error(error);
    } finally {
        submitButton.disabled = false;
        submitButton.innerHTML = 'Submit request <span aria-hidden="true">→</span>';
    }
});

document.getElementById('refresh-button').addEventListener('click', loadRequests);
loadRequests();
