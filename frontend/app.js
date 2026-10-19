const requestList = document.getElementById('request-list');
const requestForm = document.getElementById('request-form');
const formStatus = document.getElementById('form-status');
const submitButton = document.getElementById('submit-button');
const requestCount = document.getElementById('request-count');
const refreshButton = document.getElementById('refresh-button');
const searchInput = document.getElementById('search-requests');
const categoryFilter = document.getElementById('filter-category');
const statusFilter = document.getElementById('filter-status');
const clearFiltersButton = document.getElementById('clear-filters');
const statusCounts = {
    open: document.getElementById('open-count'),
    progress: document.getElementById('progress-count'),
    resolved: document.getElementById('resolved-count')
};
let allRequests = [];

async function loadRequests() {
    requestList.replaceChildren(makeMessage('Loading requests…'));
    refreshButton.disabled = true;
    refreshButton.classList.add('is-loading');

    try {
        const response = await fetch('/api/get_requests.php');
        const result = await response.json();

        if (!response.ok || !result.success) {
            throw new Error(result.error || 'Could not load requests.');
        }

        allRequests = result.requests;
        renderRequests();
    } catch (error) {
        allRequests = [];
        requestCount.textContent = 'Unavailable';
        updateStatusCounts([]);
        requestList.replaceChildren(makeMessage('Requests are temporarily unavailable. Please refresh in a moment.', 'error-state'));
        console.error(error);
    } finally {
        refreshButton.disabled = false;
        refreshButton.classList.remove('is-loading');
    }
}

function renderRequests() {
    const query = searchInput.value.trim().toLocaleLowerCase();
    const category = categoryFilter.value;
    const status = statusFilter.value;
    const filteredRequests = allRequests.filter((request) => {
        const searchableText = `${request.title} ${request.description} ${request.category}`.toLocaleLowerCase();
        return (!query || searchableText.includes(query))
            && (!category || request.category === category)
            && (!status || request.status === status);
    });

    updateStatusCounts(allRequests);
    clearFiltersButton.hidden = !query && !category && !status;

    if (allRequests.length === 0) {
        requestCount.textContent = '0 requests';
        requestList.replaceChildren(makeMessage('No requests yet. Submit the first one.'));
        return;
    }

    requestCount.textContent = filteredRequests.length === allRequests.length
        ? `${allRequests.length} ${allRequests.length === 1 ? 'request' : 'requests'}`
        : `${filteredRequests.length} of ${allRequests.length} shown`;

    if (filteredRequests.length === 0) {
        requestList.replaceChildren(makeMessage('No requests match these filters. Try a different search.'));
        return;
    }

    requestList.replaceChildren(...filteredRequests.map(makeRequestCard));
}

function updateStatusCounts(requests) {
    statusCounts.open.textContent = requests.filter((request) => request.status === 'Open').length;
    statusCounts.progress.textContent = requests.filter((request) => request.status === 'In progress').length;
    statusCounts.resolved.textContent = requests.filter((request) => request.status === 'Resolved').length;
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
    formStatus.classList.remove('is-error');
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
        formStatus.classList.add('is-error');
        console.error(error);
    } finally {
        submitButton.disabled = false;
        submitButton.innerHTML = 'Submit request <span aria-hidden="true">→</span>';
    }
});

refreshButton.addEventListener('click', loadRequests);
searchInput.addEventListener('input', renderRequests);
categoryFilter.addEventListener('change', renderRequests);
statusFilter.addEventListener('change', renderRequests);
clearFiltersButton.addEventListener('click', () => {
    searchInput.value = '';
    categoryFilter.value = '';
    statusFilter.value = '';
    renderRequests();
    searchInput.focus();
});
loadRequests();
