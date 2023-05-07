const form = document.getElementById('movement-buttons');
form.addEventListener('click', (event) => {
    const buttonId = event.target.id;
    console.log(buttonId);
    let window = document.getElementById('position-window');
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
            symbol = '0';
            break;
        }
        const jsonTransaction = {
            direction : symbol,
            window : window.innerText
        }
        console.log(typeof(window.innerText));
        fetch(`/products/movement`, {
            method: "POST",
            body: JSON.stringify(jsonTransaction),
            headers: {
                "Content-Type": "application/json",
            },
        })
        .then(res => res.json())
        .then(payload => {
            if(payload.msg === 'Comando no válido'){
                setTimeout(function () {
                    // Display an alert after the timeout
                    alert(payload.msg);
                }, 500);
                window.innerText = `${payload.data}`;
            }else{
                window.innerText = `${payload.data}`;
            }
        })
        .catch(error => { console.log(error) });
})