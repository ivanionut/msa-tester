/**
 * This is the parent controller file that all your controllers should extend.
 * You can add functions to this file to make them available in all your controllers.
 * Do not delete this file.
 *
 * NOTE: When extending this controller and implementing `config()` in the child controller, don't forget to call this
 * base controller's `config()` via `super.config()`, or else the call to `protectsFromForgery` below will be skipped.
 *
 * Example controller extending this one:
 *
 * component extends="Controller" {
 *   function config() {
 *     // Call parent config method
 *     super.config();
 *
 *     // Your own config code here.
 *     // ...
 *   }
 * }
 */
component extends="wheels.Controller" {
	function config() {
		protectsFromForgery();
	}

	private array function queryToStructs(any resultSet) {
        var results = [];

        for (entity in resultSet) {
            var resultStruct = {};

            for (columnName in resultSet.getColumnNames()) {

                // This is where you can apply custom rules for renaming your columns
                // Typicaly we used to prefix expected string type with an empty space with coldfusion

                resultStruct[columnName] = entity[columnName];
            }

            arrayAppend(results, resultStruct);
        }

        return results;
    }
}
