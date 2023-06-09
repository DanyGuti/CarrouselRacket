const productsList = document.getElementById('products-list');
const closeDropdown = document.getElementById('close-lists');
const productsDiv = document.getElementById('products');
const stylesInputs = ['rounded-lg', 'text-center', 'p-2'];
const stylesForm = ['rounded-lg', 'text-center', 'p-4', 'bg-neutral-400'];
const stylesButton = ['bg-blue-500', 'hover:bg-blue-700', 'text-white', 'font-bold', 'py-2', 'px-4', 'rounded'];

closeDropdown.addEventListener('click', (event) => {
    const childLists = productsList.querySelectorAll('list');
    const window = document.getElementById('window');
    const movements = document.getElementById('movements');
    if (childLists && !(productsList.classList.contains('hidden'))) {
        productsList.classList.toggle('hidden');
        closeDropdown.classList.add('hidden');
        setTimeout(() => {
            window.classList.remove('hidden');
            movements.classList.remove('hidden');
        }, 1250)
    }
})

function fetchProducts (event, keyProduct, inventory) {
    let inventoryUpdate = inventory;
    if(event.type !== 'transactionMade') {
        event.preventDefault();
    }else{
        fetch(`/products/update?product=${(keyProduct.substring(0,1))}`)
        .then(res => res.json())
        .then(data => {
            console.log("Success");
            let mainWindow = document.getElementById('position-window');
            let constructWindow = '';
            let listProducts = document.getElementById("products-list");
            listProducts.innerHTML = '';
            data.productObjects.forEach(product => {
                let li = document.createElement('li');
                li.id = `list_product_${product}`
                li.classList.add('p-2', 'hover:border', 'hover:border-gray-100', 'hover:border-2', 'cursor-pointer', 'rounded-lg');
                li.innerHTML = `Product: ${product['product']} Price: ${product['price']} Quantity: ${product['quantity']}`;
                li.onclick = (event) => {
                    inputProduct(product['product'], product['price'], product['quantity'], product['index'], inventoryUpdate, event);
                }
                listProducts.appendChild(li);
                if(product['product'] == keyProduct){
                    li.id = `list_product_${product}`
                    li.classList.add('p-2', 'hover:border', 'hover:border-gray-100', 'hover:border-2', 'cursor-pointer', 'rounded-lg');
                    li.innerHTML = `Product: ${product['product']} Price: ${product['price']} Quantity: ${product['quantity']}`;
                    li.onclick = (event) => {
                        inputProduct(product['product'], product['price'], product['quantity'], product['index'], inventoryUpdate, event);
                    }
                    constructWindow = `${product['product']} ${product['price']} ${product['index']} ${product['quantity']}`;
                }
            })
            mainWindow.innerText = constructWindow;
        })
        .catch(error => {console.log(error)});
    }
    fetch(`/products/products?key=${(keyProduct.substring(0, 1)) }&inventory=${inventoryUpdate}`)
    .then(res => res.json())
    .then(data =>{
        let listProducts = document.getElementById("products-list");
        if(listProducts.classList.contains('hidden')){
            listProducts.classList.toggle('hidden');
            if(closeDropdown.classList.contains('hidden')){
                closeDropdown.classList.toggle('hidden');
            }
        } else{
            if (closeDropdown.classList.contains('hidden')) {
                closeDropdown.classList.remove('hidden');
            }
        }
        listProducts.innerHTML = '';
        data.productObjects.forEach(product => {
            let li = document.createElement('li');
            li.id = `list_product_${product}`
            li.classList.add('p-2', 'hover:border', 'hover:border-gray-100', 'hover:border-2', 'cursor-pointer', 'rounded-lg');
            li.innerHTML = `Product: ${product['product']} Price: ${product['price']} Quantity: ${product['quantity']}`;
            li.onclick = (event) => {
                inputProduct(product['product'], product['price'], product['quantity'], product['index'], inventoryUpdate, event);
            }
            listProducts.appendChild(li);
        })
         
    })
    .catch(error => console.log(error));
}

document.addEventListener('transactionMade', (event) => {
    const {inventory, payloadData, product} = event.detail;
    fetchProducts(event, product.substring(0, 2), inventory);
    const transactionsDiv = document.getElementById('transactions');
    for (let i = transactionsDiv.children.length - 1; i >= 0; i--) {
        const node = transactionsDiv.children[i];
        if (node.id !== 'close-list') {
            transactionsDiv.removeChild(node);
        }
    }
    const divChild = document.createElement('dialog');
    divChild.id = "modal";
    divChild.classList.add('w-2/4', 'rounded-lg', 'text-center')
    const transactionsMade = document.createElement('p');
    const buttonModal = document.createElement('button');
    buttonModal.innerText = "Cerrar";
    buttonModal.classList.add(...stylesButton);
    transactionsMade.innerHTML = `${payloadData}`;
    buttonModal.addEventListener('click', (event) =>{
        divChild.close();
    })
    divChild.appendChild(transactionsMade);
    divChild.appendChild(buttonModal);
    transactionsDiv.appendChild(divChild);
    divChild.setAttribute('open', '');
    const window = document.getElementById('window');
    const movements = document.getElementById('movements');
    window.classList.remove('hidden');
    movements.classList.remove('hidden');
})

function inputProduct(product, price, quantity, index, inventory, event) {
    event.stopPropagation();
    const window = document.getElementById('window');
    const movements = document.getElementById('movements');
    window.classList.add('hidden');
    movements.classList.add('hidden');

    // create form elements
    const form = document.getElementById("input-bar-add-retire");
    const inputAdd = document.createElement("input");
    const labelAdd = document.createElement("label");
    const inputRetire = document.createElement("input");
    const labelRetire = document.createElement("label");
    const button = document.createElement("button");

    // set attributes for form elements
    inputAdd.type = "number";
    inputAdd.min = 0;
    inputAdd.id = `add_${product}`;
    inputAdd.placeholder = "Add quantity " + `${product}`;
    inputRetire.type = "number";
    inputRetire.min = 0;
    inputRetire.id = `retire_${product}`;
    inputRetire.placeholder = "Retire quantity " + `${product}`;
    labelAdd.htmlFor = `add_${product}`;
    labelAdd.textContent = "Add quantity:";
    labelRetire.htmlFor = `retire_${product}`;
    labelRetire.textContent = "Retire quantity:";
    button.textContent = "Submit";
    button.classList.add(...stylesButton);

    // add form elements to form
    form.innerHTML = "";
    form.appendChild(labelAdd);
    form.appendChild(inputAdd);
    form.appendChild(labelRetire);
    form.appendChild(inputRetire);
    form.appendChild(button);
    form.classList.add(...stylesForm);
    const inputs = document.querySelectorAll('input');
    inputs.forEach(input => {
        input.classList.add(...stylesInputs);
    })
    // show form
    form.classList.remove("hidden");
    document.addEventListener('click', (event) => {
        if(!form.contains(event.target) &&
         (event.target.id !== `add_${product}` || 
         event.target.id !== `retire_${product}`)){
            form.classList.add('hidden');
        }
    })
    // handle form submission
    form.addEventListener("submit", (event) => {
        event.preventDefault(); // prevent default form submission
        const inputAddValue = inputAdd.value;
        const inputRetireValue = inputRetire.value;
        if (inputAddValue || inputRetireValue) {
            const jsonTransaction = {
                addTransaction: [product, inputAddValue || 0],
                retireTransaction: [product, inputRetireValue || 0],
            };
            fetch("/products/postfile", {
                method: "POST",
                body: JSON.stringify(jsonTransaction),
                headers: {
                    "Content-Type": "application/json",
                },
            })
            .then((res) => res.json())
            .then((payload) => {
                if (payload) {
                    form.reset();
                    form.classList.add("hidden"); // hide form
                    const payloadData = payload.data;
                    const transactionEvent = new CustomEvent('transactionMade', { detail: {payloadData, product, inventory} });
                    document.dispatchEvent(transactionEvent);
                }
                else{
                    console.log("No transaction made");
                }
            })
            .catch((error) => {
                console.log(error);
            });
        }
    });
}

function transactionActual(event, inventory){
    event.preventDefault();
    const buttonNoWindow = document.getElementById('position-window');
    const product = (buttonNoWindow.innerText).substring(0, 2);
    const price = (buttonNoWindow.innerText).substring(3, 6);
    const index = (buttonNoWindow.innerText).substring(7, 8);
    const quantity = (buttonNoWindow.innerText).substring(9, 12);
    const parent = document.getElementById('window-child');
    const modalWindow = document.createElement('dialog');
    modalWindow.id ='modalWindow';
    
    const form = document.createElement('form');
    const inputAdd = document.createElement("input");
    const labelAdd = document.createElement("label");
    const inputRetire = document.createElement("input");
    const labelRetire = document.createElement("label");
    const button = document.createElement("button");

    // set attributes for form elements
    inputAdd.type = "number";
    inputAdd.min = 0;
    inputAdd.id = `add_${product}`;
    inputAdd.placeholder = "Add quantity " + `${product}`;
    inputRetire.type = "number";
    inputRetire.min = 0;
    inputRetire.id = `retire_${product}`;
    inputRetire.placeholder = "Retire quantity " + `${product}`;
    labelAdd.htmlFor = `add_${product}`;
    labelAdd.textContent = "Add quantity:";
    labelRetire.htmlFor = `retire_${product}`;
    labelRetire.textContent = "Retire quantity:";
    button.textContent = "Submit";
    button.classList.add(...stylesButton);

    // add form elements to form
    form.innerHTML = "";
    form.appendChild(labelAdd);
    form.appendChild(inputAdd);
    form.appendChild(labelRetire);
    form.appendChild(inputRetire);
    form.appendChild(button);
    form.classList.add(...stylesForm);
    const inputs = document.querySelectorAll('input');
    inputs.forEach(input => {
        input.classList.add(...stylesInputs);
    })
    const buttonModal = document.createElement('button');
    buttonModal.innerText = "Cerrar";
    buttonModal.classList.add(...stylesButton);
    buttonModal.addEventListener('click', (event) => {
        modalWindow.close();
    })
    modalWindow.appendChild(form);
    modalWindow.appendChild(buttonModal);
    parent.appendChild(modalWindow);
    modalWindow.setAttribute('open', '');
    // show form
    form.addEventListener("submit", (event) => {
        event.preventDefault(); // prevent default form submission
        const inputAddValue = inputAdd.value;
        const inputRetireValue = inputRetire.value;
        if (inputAddValue || inputRetireValue) {
            const jsonTransaction = {
                addTransaction: [product, inputAddValue || 0],
                retireTransaction: [product, inputRetireValue || 0],
            };
            fetch("/products/postfile", {
                method: "POST",
                body: JSON.stringify(jsonTransaction),
                headers: {
                    "Content-Type": "application/json",
                },
            })
            .then((res) => res.json())
            .then((payload) => {
                if (payload) {
                    form.reset();
                    form.classList.add("hidden"); // hide form
                    const payloadData = payload.data;
                    const transactionEvent = new CustomEvent('transactionMade', { detail: { payloadData, product, inventory } });
                    document.dispatchEvent(transactionEvent);
                }
                else {
                    console.log("No transaction made");
                }
            })
            .catch((error) => {
                console.log(error);
            });
        }
    });
}
