<cfscript>
  // Place functions here that should be available globally in your application.

  //=====================================================================
//= 	Global Functions
//=====================================================================
if (StructKeyExists(server, "lucee")) {
	include "logging.cfm";
} else {
	// TODO: Check this doesn't break when in a subdir?
	include "/global/logging.cfm";
}

/**
	 *
	 * adds support for DCE compliant guid in coldfusion
	 *
	 * [section: Utility]
	 * [category: Global]
	 * 
	 */
	public string function createGenericGUID() {
	    if (structKeyExists(server, "lucee")) {
	        return createGUID();
	    } else {
	    	var uuidLibObj = createobject("java", "java.util.UUID");

   			return uuidLibObj.randomUUID().toString();
	    }
	}
</cfscript>
