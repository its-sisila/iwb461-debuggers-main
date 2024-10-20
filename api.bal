import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;

// Define MySQL database configuration
mysql:Client|sql:Error dbClient = new ({
    host: "localhost",
    port: 3306,
    username: "your_username",
    password: "your_password",
    database: "your_database"
});

// Check if client is created successfully
service /recipe on new http:Listener(8080) {

    // Resource to search recipes by ingredient or recipe name
    resource function get search(string ingredientOrMeal) returns json|error {
        string query = "SELECT * FROM recipes WHERE recipe_name LIKE ? OR ingredients LIKE ?";

        // Use a parameterized query
        sql:ParameterizedQuery paramQuery = check sql:parameterize(query, "%" + ingredientOrMeal + "%", "%" + ingredientOrMeal + "%");

        // Execute the query
        sql:Result result = check dbClient->query(paramQuery);

        // Convert results to JSON
        json results = [];
        while result.next() {
            results.push(result.get());
        }
        return results;
    }

    // Resource to add a new recipe
    resource function post add(json recipe) returns json|error {
        string query = "INSERT INTO recipes (recipe_name, ingredients, steps) VALUES (?, ?, ?)";
        check dbClient->update(query, recipe.recipe_name.toString(), recipe.ingredients.toString(), recipe.steps.toString());
        return {message: "Recipe added successfully"};
    }

    // Resource to delete a recipe by ID
    resource function delete remove(int recipeId) returns json|error {
        string query = "DELETE FROM recipes WHERE id = ?";
        check dbClient->update(query, recipeId);
        return {message: "Recipe deleted successfully", id: recipeId};
    }

    // Resource to update a recipe
    resource function put update(int recipeId, json recipe) returns json|error {
        string query = "UPDATE recipes SET recipe_name = ?, ingredients = ?, steps = ? WHERE id = ?";
        check dbClient->update(query, recipe.recipe_name.toString(), recipe.ingredients.toString(), recipe.steps.toString(), recipeId);
        return {message: "Recipe updated successfully", id: recipeId};
    }
}
