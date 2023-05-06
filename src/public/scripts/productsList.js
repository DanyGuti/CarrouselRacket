const productsList = document.getElementById('products-list');
const closeDropdown = document.getElementById('close-lists');
const productsDiv = document.getElementById('products');

closeDropdown.addEventListener('click', (event) => {
    const childLists = productsList.querySelectorAll('list');
    if (childLists && !(productsList.classList.contains('hidden'))) {
        productsList.classList.toggle('hidden');
        closeDropdown.classList.add('hidden');
    }
})

function fetchProducts (event, keyProduct, inventory) {
    event.preventDefault();
    fetch(`/products/products?key=${keyProduct}&inventory=${inventory}`)
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
            li.classList.add('p-2', 'hover:z-10', 'hover:border', 'hover:border-gray-100', 'hover:border-2', 'cursor-pointer', 'rounded-lg');
            li.innerHTML = `Product: ${product['product']} Price: ${product['price']} Quantity: ${product['quantity']}`;
            li.onclick = (event) => {
                inputProduct(product['product'], product['price'], product['quantity'], product['index'], event);
            }
            listProducts.appendChild(li);
        })
         
    })
    .catch(error => console.log(error));
}


function inputProduct(product, price, quantity, index, event) {
    event.stopPropagation();
    const stylesInputs = ['rounded-lg', 'text-center', 'p-2'];
    const stylesForm = ['rounded-lg', 'text-center', 'p-4', 'bg-neutral-400'];
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
    button.classList.add("bg-blue-500", "hover:bg-blue-700", "text-white", "font-bold", "py-2", "px-4", "rounded");

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
                    console.log("success");
                    form.reset();
                    form.classList.add("hidden"); // hide form
                }
            })
            .catch((error) => {
                console.log(error);
            });
        }
    });
}