// script.js
// just a bit of JS for form validation / UX, nothing that the
// backend depends on

// confirm before sending money since it can't be undone once it goes through
const transferForm = document.getElementById("transfer-form");
if (transferForm) {
    transferForm.addEventListener("submit", function (event) {
        const amount = document.getElementById("amount").value;
        const from = document.getElementById("from_account").value;
        const to = document.getElementById("to_account").value;
        const confirmed = confirm(
            `Transfer ${amount} from account ${from} to account ${to}?`
        );
        if (!confirmed) {
            event.preventDefault();
        }
    });
}

// quick check so the login form isn't submitted empty
// (the actual check still happens in app.py, this is just for convenience)
const loginForm = document.getElementById("login-form");
if (loginForm) {
    loginForm.addEventListener("submit", function (event) {
        const username = document.getElementById("username").value.trim();
        const password = document.getElementById("password").value.trim();
        if (username === "" || password === "") {
            alert("Both username and password are required.");
            event.preventDefault();
        }
    });
}

// filter the customer table on the page as you type, no server call needed
const customerTable = document.getElementById("customer-table");
if (customerTable) {
    const searchBox = document.createElement("input");
    searchBox.setAttribute("placeholder", "Filter customers on this page...");
    customerTable.parentNode.insertBefore(searchBox, customerTable);

    searchBox.addEventListener("keyup", function () {
        const filter = searchBox.value.toLowerCase();
        const rows = customerTable.getElementsByTagName("tr");
        for (let i = 1; i < rows.length; i++) {
            const rowText = rows[i].textContent.toLowerCase();
            rows[i].style.display = rowText.includes(filter) ? "" : "none";
        }
    });
}
