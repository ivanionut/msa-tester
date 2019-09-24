component extends="Model" {

	public void function config() {
		table("tbl_student_user");
	}

	public query function generateRandomUsersForFreeMsa(required numeric itemNo) {
		
		var customQuery = "
            SELECT TOP (:pItemNo)
				  Username
				, First_Name AS FirstName
				, Last_Name AS LastName
				, Phone
			FROM tbl_student_user 
			WHERE Phone IS NOT NULL
			ORDER BY createdAt DESC
        ";
        
        var parameters = {
            pItemNo = {value=itemNo, CFSQLType="CF_SQL_INTEGER"}
        };

        var options = {
            datasource='mysafetyassistant'
        };

        return queryExecute(customQuery, parameters, options);
	}
}