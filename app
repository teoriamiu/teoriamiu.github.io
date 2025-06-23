
const foodSelect = document.getElementById('foodSelect');
const gramsInput = document.getElementById('gramsInput');
const foodTableBody = document.querySelector('#foodTable tbody');
const totalsP = document.getElementById('totals');

let foods = [];
let nutrients = [];
let foodNutrients = [];
let addedFoods = [];

function loadCSV(url, callback) {
    Papa.parse(url, {
        download: true,
        header: true,
        complete: function(results) {
            callback(results.data);
        }
    });
}

function loadAllCSVs() {
    loadCSV('https://github.com/calculadoranutricional/calculadoranutricional.github.io/raw/main/food.csv', data => {
        foods = data;
        populateFoodSelect();
    });
    loadCSV('https://github.com/calculadoranutricional/calculadoranutricional.github.io/raw/main/nutrient.csv', data => {
        nutrients = data;
    });
    loadCSV('https://github.com/calculadoranutricional/calculadoranutricional.github.io/raw/main/food_nutrient.csv', data => {
        foodNutrients = data;
    });
}

function populateFoodSelect() {
    foods.forEach(food => {
        const option = document.createElement('option');
        option.value = food.fdc_id;
        option.textContent = food.description;
        foodSelect.appendChild(option);
    });
}

function addFood() {
    const foodId = foodSelect.value;
    const grams = parseFloat(gramsInput.value);
    const food = foods.find(f => f.fdc_id === foodId);
    const nutrientsForFood = foodNutrients.filter(fn => fn.fdc_id === foodId);

    let calories = 0, protein = 0, fat = 0, carbs = 0;

    nutrientsForFood.forEach(fn => {
        const nutrientInfo = nutrients.find(n => n.id === fn.nutrient_id);
        if (!nutrientInfo) return;
        const amountPer100g = parseFloat(fn.amount);
        const amount = amountPer100g * (grams / 100);

        if (nutrientInfo.name.toLowerCase().includes('energy')) calories += amount;
        if (nutrientInfo.name.toLowerCase().includes('protein')) protein += amount;
        if (nutrientInfo.name.toLowerCase().includes('total lipid')) fat += amount;
        if (nutrientInfo.name.toLowerCase().includes('carbohydrate')) carbs += amount;
    });

    addedFoods.push({ name: food.description, grams, calories, protein, fat, carbs });
    renderTable();
}

function renderTable() {
    foodTableBody.innerHTML = '';
    let totalCalories = 0, totalProtein = 0, totalFat = 0, totalCarbs = 0;

    addedFoods.forEach(item => {
        totalCalories += item.calories;
        totalProtein += item.protein;
        totalFat += item.fat;
        totalCarbs += item.carbs;

        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${item.name}</td>
            <td>${item.grams}</td>
            <td>${item.calories.toFixed(2)}</td>
            <td>${item.protein.toFixed(2)}</td>
            <td>${item.fat.toFixed(2)}</td>
            <td>${item.carbs.toFixed(2)}</td>
        `;
        foodTableBody.appendChild(row);
    });

    totalsP.textContent = `Calorías: ${totalCalories.toFixed(2)} kcal | Proteínas: ${totalProtein.toFixed(2)} g | Grasas: ${totalFat.toFixed(2)} g | Carbohidratos: ${totalCarbs.toFixed(2)} g`;
}

loadAllCSVs();
