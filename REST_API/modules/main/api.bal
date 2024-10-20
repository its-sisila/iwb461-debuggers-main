import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;

// Define MySQL database configuration
mysql:Client dbClient = new ({
    host: "localhost",
    port: 3306,
    username: "your_username",
    password: "your_password",
    database: "your_database"
});

service /recipe on new http:Listener(8080) {

    // Resource to search recipes by ingredient or recipe name
    resource function get search(string ingredientOrMeal) returns json {
        // Query to search for recipes that match the ingredient or name
        string query = "SELECT * FROM recipes WHERE recipe_name LIKE ? OR ingredients LIKE ?";
        json results = check dbClient->query(query, "%" + ingredientOrMeal + "%", "%" + ingredientOrMeal + "%");
        return results;
    }

    // Resource to add a new recipe
    resource function post add(json recipe) returns json {
        string query = "INSERT INTO recipes (recipe_name, ingredients, steps) VALUES (?, ?, ?)";
        json newRecipe = check dbClient->update(query, recipe.recipe_name.toString(), recipe.ingredients.toString(), recipe.steps.toString());
        return {message: "Recipe added successfully", id: newRecipe};
    }

    // Resource to delete a recipe by ID
    resource function delete remove(int recipeId) returns json {
        string query = "DELETE FROM recipes WHERE id = ?";
        json deleteResult = check dbClient->update(query, recipeId);
        return {message: "Recipe deleted successfully", id: recipeId};
    }

    // Resource to update a recipe
    resource function put update(int recipeId, json recipe) returns json {
        string query = "UPDATE recipes SET recipe_name = ?, ingredients = ?, steps = ? WHERE id = ?";
        json updateResult = check dbClient->update(query, recipe.recipe_name.toString(), recipe.ingredients.toString(), recipe.steps.toString(), recipeId);
        return {message: "Recipe updated successfully", id: recipeId};
    }
}
