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
</cfscript>
