import axios from 'axios';

document.addEventListener('DOMContentLoaded', () => {
    const fetchBankers = async () => {
        try {
            const response = await axios.get('http://localhost:3000/api/bankers');
            const tableBody = document.querySelector('#bankers-table tbody');
            response.data.forEach(row => {
                const newRow = document.createElement('tr');
                Object.values(row).forEach(cell => {
                    const newCell = document.createElement('td');
                    newCell.textContent = cell;
                    newRow.appendChild(newCell);
                });
                tableBody.appendChild(newRow);
            });
        } catch (error) {
            console.error('Failed to fetch bankers:', error);
            const errorMessage = document.createElement('div');
            errorMessage.textContent = 'Error fetching data. Please try again later.';
            errorMessage.classList.add('alert', 'alert-danger');
            document.body.appendChild(errorMessage);
        }
    };

    fetchBankers();
});
