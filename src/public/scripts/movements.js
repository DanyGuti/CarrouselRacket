const form = document.getElementById('movement-buttons');
form.addEventListener('click', (event) => {
    const buttonId = event.target.id;
    console.log(buttonId);
    const window = document.getElementById('position-window').innerText;
    switch(buttonId) {
        case 'left':
            symbol = '-';
            break;
        case 'right':
            symbol = '+';
            break;
        case 'up':
            symbol = '1';
            break;
        case 'down':
            symbol = '-1';
            break;
        }
        const jsonTransaction = {
            direction : symbol,
            window : window
        }
        fetch(`/products/movement`, {
            method: "POST",
            body: JSON.stringify(jsonTransaction),
            headers: {
                "Content-Type": "application/json",
            },
        })
            .then(res => res.json())
            .then()
            .catch(error => { console.log(error) });
})