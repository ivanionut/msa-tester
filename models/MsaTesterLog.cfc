component extends="Model"{

	public void function config() {
		table("MsaTesterLogs");
	}

	public void function updateLogTableCompanyId(required numeric companyId, required string companyName) {
		addInfoLog("updateLogTableCompanyId()"," Update log table for company name :" & companyName & " company id : " & companyId);
		var customQuery = "
            UPDATE MsaTesterLogs
				SET companyId = :pCompanyId
			WHERE	companyName = :pCompanyName
        ";
        
        var parameters = {
            pCompanyId = {value=companyId, CFSQLType="CF_SQL_INTEGER"},
            pCompanyName = {value=companyName, CFSQLType="CF_SQL_NVARCHAR"}
        };

        var options = {
            datasource='mysafetyassistant'
        };

        queryExecute(customQuery, parameters, options);
        addInfoLog("updateLogTableCompanyId()","Updated company id in the log table for company name :" & companyName);
        return;
	}
}
