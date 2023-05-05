function fetchProducts (event, keyProduct, inventory) {
    event.preventDefault();
    fetch(`/products/products?key=${keyProduct}&inventory=${inventory}`)
    .then(res => res.json())
    .then(data =>{
        let listProducts = document.getElementById("products-list");
        listProducts.innerHTML = '';
        data.productObjects.forEach(product => {
            let li = document.createElement('li');
            li.classList.add('p-2', 'hover:z-10', 'hover:border', 'hover:border-gray-100', 'hover:border-2', 'cursor-pointer', 'rounded-lg');
            li.innerHTML = `Product: ${product['product']} Price: ${product['price']} Quantity: ${product['quantity']}`;
            li.onclick = (event) => {
                event.stopPropagation();
                inputProduct(product['product'], product['price'], product['quantity'], product['index'], event);
            }
            listProducts.appendChild(li);
        })
         
    })
    .catch(error => console.log(error));
}

function inputProduct (product, price, quantity, index, event) {
    let form = document.getElementById("input-bar-add-retire");
    if(!form){
        let form = document.createElement("form");
        form.id = "input-bar-add-retire";
        console.log(form);
        document.getElementById("products").appendChild(form);
        form.classList.add('flex', 'flex-col', 'justify-center', 'text-center');
        form.classList.add('z-40', 'fixed', 'w-3/12', 'bg-zinc-100', 'bottom-32', 'p-5', 'rounded-lg', 'items-center');
    } else{
        form.classList.add('z-40', 'fixed', 'w-3/12', 'bg-zinc-100', 'bottom-32', 'p-5', 'rounded-lg', 'items-center');
    }
    let existingInputs = form.querySelectorAll("input");
    let existingButton = form.querySelector("button");
    if (existingInputs.length === 2 && existingButton) {
        // input fields already exist, update their attributes
        existingInputs[0].id = `add_${product}`;
        existingInputs[0].name = `add_${product}`;
        existingInputs[0].value = "";
        existingInputs[1].id = `retire_${product}`;
        existingInputs[1].name = `retire_${product}`;
        existingInputs[1].value = "";
        existingButton.id = `button_${product}`;
        existingButton.type = 'submit';

        // update labels
        let labels = form.querySelectorAll("label");
        labels[0].textContent = `Add to product: ${product}`;
        labels[0].htmlFor = `add_${product}`;
        labels[1].textContent = `Retire from product: ${product}`;
        labels[1].htmlFor = `retire_${product}`;
        existingButton.textContent = `Accept transactions ${product}`;
    } else {
        // input fields don't exist yet, create them
        let inputAdd = document.createElement("input");
        inputAdd.id = `add_${product}`;
        inputAdd.name = `add_${product}`;
        inputAdd.type = "number";
        inputAdd.classList.add('bg-gray-200', 'border', 'border-gray-300', 'text-gray-900', 'text-sm', 'rounded-lg', 'focus:ring-gray-500', 'text-center', 'w-2/4');

        let labelAdd = document.createElement("label");
        labelAdd.classList.add('rounded-xl', 'text-gray-900');
        labelAdd.textContent = `Add to product: ${product} `;
        labelAdd.htmlFor = `add_${product}`;

        let inputRetire = document.createElement("input");
        inputRetire.id = `retire_${product}`;
        inputRetire.name = `retire_${product}`;
        inputRetire.type = "number";
        inputRetire.classList.add('bg-gray-200', 'border', 'border-gray-300', 'text-gray-900', 'text-sm', 'rounded-lg', 'focus:ring-gray-500', 'text-center', 'w-2/4');

        let labelRetire = document.createElement("label");
        labelRetire.classList.add('rounded-xl', 'text-gray-900');
        labelRetire.textContent = `Retire from product: ${product} `;
        labelRetire.htmlFor = `retire_${product}`;
        
        let button = document.createElement("button");
        button.id = `button_${product}`;
        button.classList.add('p-5', 'bg-neutral-700', 'text-zinc-100', 'hover:text-neutral-700', 'hover:bg-zinc-300', 'rounded-xl');
        button.textContent = `Accept transaction ${product} `;
        button.type = 'submit';
        form.appendChild(inputAdd);
        form.appendChild(labelAdd);
        form.appendChild(inputRetire);
        form.appendChild(labelRetire);
        form.appendChild(button);
        form.addEventListener('click', ev => { ev.stopPropagation() });
        form.addEventListener('submit', (event) => {
            event.preventDefault(); // prevent default form submission
            let inputAddValue = document.getElementById(`add_${product}`).value;
            let inputRetireValue = document.getElementById(`retire_${product}`).value;
            let jsonTransaction = {};
            jsonTransaction.addTransaction = [product, inputAddValue];
            jsonTransaction.retireTransaction = [product, inputRetireValue];
            fetch (`/products/postfile`, {
                method: 'POST',
                body: JSON.stringify(jsonTransaction),
                headers: {
                    'Content-Type': 'application/json'
                }
            })
            .then(res => res.json())
            .then(payload => {
                if(payload){
                    console.log("success");
                    form.reset();
                    form.parentNode.removeChild(form);
                }
            })
            .catch((error)=> {console.log(error)});
        }
    )}
}
