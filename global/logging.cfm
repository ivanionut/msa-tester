<cfscript>
//=====================================================================
//=     Logging
//=====================================================================

/**
* Adds a logline to the Audit Log: doesn't log anything in testing mode
*
* [section: Application]
* [category: Utils]
*
* @logtype Anything you want to group by: i.e, info | debug | error etc.
* @message The Message
* @severity One of normal | warning | fatal
*/
public void function addLogLine(required string logtype="INFO",  required string methodName="", required string logMessage="", string severity="normal", string userName="", string companyName="", numeric companySize=1, datetime processStart=0, numeric success=0, numeric duration=0){
		//local.newLogLine=model("msatesterlog").create(arguments);
		var log = model("msaTesterLogs").new();
		log.logType = uCase(logtype);
		log.methodName = methodName;
		log.logMessage = logMessage;
		var sev = 1;
		if(CompareNoCase(severity, "fatal") == 0 ){
			sev =3;
		}else if(CompareNoCase(severity, "warning") == 0){
			sev = 2;
		}
		log.severity = sev;
		log.userName = userName;
		log.companyName = companyName;

		switch (companySize) {
			case 1:
				log.companySize 	= "1 to 10 employees";
				break;
			case 11:
				log.companySize 	= "11 to 50 employees";
				break;
			case 51:
				log.companySize 	= "51 to 100 employees";
				break;
			case 100:
				log.companySize 	= "More than 100 employees";
				break;
			default:
				log.companySize 	= "NA";
				break;
		}
		log.processStart = processStart == 0 ? now() : processStart;
		log.success = success;
		log.duration = duration;
		if(!log.save()){
				message = log.allErrors()[1];
				throw(serialize(message));
		}
}

</cfscript>
