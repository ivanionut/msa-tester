<cfscript>
//=====================================================================
//=     Logging
//=====================================================================

/**
* Add a info log 
* [section: Application]
* [category: Utils]
*
* @methodName Method name that log this information. (required field)
* @logMessage The Message (required field)
*/
public void function addInfoLog(required string methodName="", required string logMessage=""){
		
		var log = model("msaTesterLogs").new();

		log.logType = "INFO";
		log.methodName = methodName;
		log.logMessage = logMessage;
		log.severity = 1; //info log severity 
		log.processStart = now();
		log.isSucceed = 0; // not applicable

		if(!log.save()){
				message = log.allErrors()[1];
				throw(serialize(message));
		}
}


/**
* Adds an error log
*
* [section: Application]
* [category: Utils]
*
* @methodName Method name that log this information. (required field)
* @logMessage The Message (required field)
* @userName The user name if available
* @companyName The company name if available
* @companyId The company id if available
*/
public void function addErrorLog(required string methodName="", required string logMessage="", string userName="", string companyName="", numeric companyId){
	
		var log = model("msaTesterLogs").new();
	
		log.logType = "ERROR";
		log.methodName = methodName;
		log.logMessage = logMessage;
		log.severity = 3; //error log severity is 3 right now  
		log.isSucceed = -1; //error occured
		log.userName = isDefined("userName") ? userName : "";
		log.companyName = isDefined("companyName") ? companyName  : "";
		log.companyId = isDefined("companyId") ? companyId  : "";
		log.processStart = now();
	
		if(!log.save()){
				message = log.allErrors()[1];
				throw(serialize(message));
		}
}


/**
* Adds a debug log for saving data. which can be used later on to present 
*
* [section: Application]
* [category: Utils]
*
* @methodName Method name that log this information. (required field)
* @logMessage The Message (required field)
* @userName The user name if available
* @companyName The company name if available
* @companyId The company id if available
* @processStart The time when process start
* @isSucceed Is the process succeed
* @operationType The operation type: httppost | httpget | db
* @duration The duration took for processing the work

*/
public void function addDebugLog(required string methodName="", required string logMessage="",  string userName="", string companyName="", numeric companyId, datetime processStart, numeric isSucceed, string operationType, numeric duration){

		var log = model("msaTesterLogs").new();
		
		log.logType = "DEBUG";
		log.methodName = methodName;
		log.logMessage = logMessage;
		log.severity = 1;
		log.userName = isDefined("userName") ? userName : "";
		log.companyName = isDefined("companyName") ? companyName  : "";
		log.companyId = isDefined("companyId") ? companyId  : -1;

		log.processStart = isDefined("processStart") ? processStart : now();
		log.isSucceed = isDefined("isSucceed") ? isSucceed : 0;
		log.operationType = isDefined("operationType") ? operationType : "";
		log.duration = isDefined("duration") ? duration : 0;
		if(!log.save()){
				message = log.allErrors()[1];
				throw(serialize(message));
		}
}

</cfscript>
