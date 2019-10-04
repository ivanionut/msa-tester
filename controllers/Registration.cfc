component extends="Controller" {

	public void function config() {
		//super.config();
		provides("json");
	}

	/**
		Public end point to start registering company through free msa website
	*/
	public void function startRegister() {
		var input = 700;
		var methodName = "startRegister()";

		addInfoLog(methodName,"START: creating new companies :" & input);
		
		var userList = getUserList(input);

		var successCount = 0;
		var failedCount =0;
		for (var i=1; i<= userList.len(); i++) {
			addDebugLog(methodName,"REGISTRATION start i: "& i &" "& userList[i].companyName,userList[i].Email,userList[i].companyName,-1, now(), 0,"REG_MAIN", 0);
			
			var start = getTickCount();
			
			// regist user over http post
			var isSucceed = registerUser(userList[i]);
			if(isSucceed){
				//confirming user emails using http get
				startConfirmingEmailForCompany(userList[i].companyName);
				
				addDebugLog(methodName,"REGISTRATION completed : "& userList[i].companyName,userList[i].Email,userList[i].companyName,-1, now(), 1,"REG", getTickCount()-start);
				
				successCount++;

				//update mising company ids in the log table
				if(!updateCompanyIdInLog(userList[i].companyName)){
					addInfoLog(methodName,"UPDATE FAILED :" & input & " Failed : " & failedCount);
				}

			}else{
				var statCode = "";
				if(StructKeyExists(httpResult,"status_code")){
					statCode = httpResult.status_code;
				}
				addDebugLog(methodName,"REGISTRATION failed : "& statCode & " " & userList[i].companyName,userList[i].Email,userList[i].companyName,-1, now(), -1,"REG_MAIN", getTickCount()-start);
			}


		}
		renderWith(userList[1]);
		var failedCount = input-successCount;
		addInfoLog(methodName,"END: New companies created :" & successCount & " Failed : " & failedCount);
		return;
	}
	/**
		Public end point to invite workers through free msa website
	*/
	public void function inviteWorker(){
		var noOfcompany = 100;
		var inviteWorkers = 10;	
		var methodName = "inviteWorker()";

		addInfoLog(methodName,"START: inviting new worker :" & inviteWorkers);
		
		var companyList = model("registration").findAll(select="companyName,companyId,companySize",where="status=2",distinct = true, group ="companyId", returnAS = "objects", reload=true);

		 // renderWith(companyList);
		 if(companyList.len() < noOfcompany){
		 	noOfcompany = companyList.len();
		 }
		 var count =0;
		 for(var i=1; i <= noOfcompany; i++){

		 	var userList = getUserList(inviteWorkers,companyList[i].CompanyName,companyList[i].CompanyId);
		 	
		 	addInfoLog(methodName,"RESULT_FROM DB userlist: " &  userList.len());
			//for each company we are inviting worker input number of workers
			for (var j=1; j<= userList.len(); j++) {
				// 	as I am not using register user I need to create user with guid
				userList[j].guid = createGenericGUID();
				// new user should have company size from company list
				userList[j].CompanySize = companyList[i].CompanySize;

				addDebugLog(methodName,"REGISTRATION start : "& userList[j].companyName,userList[j].Email,userList[j].companyName, userlist[j].CompanyId, now(), 0,"INVITE", 0);
			
				var start = getTickCount();

				//mimicking the invite and create a user in the registration table
				saveUserInRegistrationTable(userList[j]);

				//Confirm new worker
				if(!completeEmployeeRegistration(userList[j])){
					var entry = model("registration").findOne(where = "email ='" & userList[j].Email &"'", reload=true);
					entry.delete();
					addDebugLog(methodName,"REGISTRATION completed : "& userList[j].companyName,userList[j].Email,userList[j].companyName, userlist[j].CompanyId, now(), 1,"INVITE",getTickCount()-start);
				
				}else{
					count++;

				addDebugLog(methodName,"REGISTRATION completed : "& userList[j].companyName,userList[j].Email,userList[j].companyName, userlist[j].CompanyId, now(), 1,"INVITE",getTickCount()-start);
				
				}

				addDebugLog(methodName,"REGISTRATION completed : "& userList[j].companyName,userList[j].Email,userList[j].companyName, userlist[j].CompanyId, now(), 1,"INVITE",getTickCount()-start);
				
			}
		}
		
		addInfoLog(methodName,"END: invitinging "& inviteWorkers & " new workers for "& noOfcompany& " companies each and employee created " & count );
		renderWith(userList[1]);
		return;
	}

	/**
	* Register new user/company through http post call 
	*
	* [section: Application]
	* [category: Utils]
	*
	* @user User to create. (required field)
	*/
	private boolean function registerUser(required struct user){
		var methodName = "registerUser()";
		var processStart = now();
		addInfoLog(methodName,"START: for " & user.Email);

		addDebugLog(methodName,"REGISTRATION start for: "& user.companyName,user.Email,user.companyName,-1, processStart, 0,"http post", 0);
		var start = getTickCount();
		cfhttp(method="post",redirect="no", charset="utf-8", url="#get('baseURL')#/company-register", result="httpResult") {
			cfhttpparam(type="formfield", name="firstname", value=user.FirstName);
			cfhttpparam(type="formfield", name="lastname", value=user.LastName); 
			cfhttpparam(type="formfield", name="email", value=user.Email);
			cfhttpparam(type="formfield", name="password", value=user.Password);
			cfhttpparam(type="formfield", name="password-confirm", value=user.Password);
			cfhttpparam(type="formfield", name="companyName", value=user.CompanyName);
			cfhttpparam(type="formfield", name="phone", value=ToString(user.Phone));
			cfhttpparam(type="formfield", name="size", value=user.CompanySize);
		}
		
		var isRegistered = false;
		if(StructKeyExists(httpResult, "responseHeader")){
			if(StructKeyExists(httpResult.responseHeader, "Status_Code" )){
				if (httpResult.responseHeader.Status_Code == "302"){
					addInfoLog(methodName,serialize(httpResult));
					var location = ToString(decodeFromURL(httpResult.responseHeader.location));
					addDebugLog(methodName,"REGISTRATION Failed: " & right(location,40),	user.Email,  user.companyName, user.CompanyId, processStart, -1,"http post " & httpResult.responseHeader.Status_Code, getTickCount()-start);					
				}else if (httpResult.responseHeader.Status_Code != "200"){
				 	
					addErrorLog(methodName,"http post returned with the status code -- " & httpResult.responseHeader.Status_Code,user.Email,user.companyName, user.companyId);

					addDebugLog(methodName,"REGISTRATION Failed: " & user.companyName,user.companyName, user.CompanyId, processStart, -1,"http post " & httpResult.responseHeader.Status_Code, getTickCount()-start);
				}else{
					isRegistered = true;
					addDebugLog(methodName,"REGISTRATION Success for: "& user.companyName,user.Email,user.companyName,-1, processStart, 1,"http post "& httpResult.responseHeader.Status_Code, getTickCount()-start);
				}
			}
		}else if(StructKeyExists(httpResult,"status_code")){
			addDebugLog(methodName,"REGISTRATION failed for "& user.companyName,user.Email,user.companyName, user.CompanyId, processStart, -1,"http post "& httpResult.status_code, getTickCount()-start);

		}

		addInfoLog(methodName,"END: register" & user.Email);

		return isRegistered;
	}

	/**
	* Get random users from database. If company name is provided (while inviting worker) then new user will belong to that company. The company name and id should be matched with existing companies in the registration table.
	*
	* [section: Application]
	* [category: Utils]
	*
	* @input No of users to create. (required field)
	* @companyName Company name of that user to be. (optional) 
	* @companyId Company id of that user to be. (optional)
	*/
	private any function getUserList(required numeric input, string companyName, numeric companyId){
		var methodName = "getUserList()";

		var userList = queryToStructs(model("User").generateRandomUsersForFreeMsa(input));

		addInfoLog(methodName,"START fetch from DB ::" &  userList.len());

		for (var i=1; i <= userList.len(); i++) {

			userList[i].Password = "test123";

			var randNum = RandRange(1, 10000);

			if(isDefined("companyName")){
				userList[i].CompanyName = companyName;
			}else{
				userList[i].CompanyName = userList[i].LastName & " Company " & randNum;
			}

			if(isDefined("companyId")){
				userList[i].CompanyId = companyId;
			}else{
				userList[i].CompanyId = -1;
			}

			var size = 1;

			// randomly generating company size
			randNum = randNum % 5; 
			if(randNum == 4) {
				size = 100;
			} else if(randNum == 3) {
				size = 51;
			} else if(randNum == 2) {
				size = 11;
			}

			randNum = RandRange(1, 100000);
			userList[i].Email = "randomized_" & randNum &"@1lifewss.com";
			userList[i].CompanySize = size;

		}

		addInfoLog(methodName,"END return with::" &  userList.len());

		return userList;
	}

	/**
	* Confirm newly created company in free msa
	*
	* [section: Application]
	* [category: Utils]
	*
	* @companyName Company Name to confirm. (required field)
	*/
	private void function startConfirmingEmailForCompany(required string companyName){
		var methodName = "startConfirmingEmailForCompany()";
		var processStart = now();
		var isSucceed = 0;

		addInfoLog(methodName,"START: validating email adress for " & companyName);

		var company = model("registration").findOne(where ="companyName = '" & companyName &"'",returnAS = "objects"); 

		var companySize = getCompanySize(company.companySize);

		addDebugLog(methodName,"CONFIRMING Email of: "& company.CompanyName, company.Email, company.CompanyName, company.CompanyId, processStart, isSucceed,"http get", 0);
		
		var start = getTickCount();
			cfhttp(method="GET", charset="utf-8", url="#get('baseURL')#/company-confirm?", result="httpResult") {
				cfhttpparam(type="url", name="key", value="#company.guid#");
			}

			if(StructKeyExists(httpResult, "responseHeader")){
				if(StructKeyExists(httpResult.responseHeader, "Status_Code" )){
					if (httpResult.responseHeader.Status_Code == "302"){
						addInfoLog(methodName,serialize(httpResult));
						var location = ToString(decodeFromURL(httpResult.responseHeader.location));
						addDebugLog(methodName,"REGISTRATION Failed: " & right(location,40), company.companyName, company.CompanyId, processStart, -1,"http post " & httpResult.responseHeader.Status_Code, getTickCount()-start);					
					}else if (httpResult.responseHeader.Status_Code != "200") {
						isSucceed = -1;
						addErrorLog(methodName,"http get returned with the status code -- " & httpResult.responseHeader.Status_Code, company.Email, company.companyName,user.companyId);
						
						addDebugLog(methodName,"CONFIRMATION failed for: " & company.companyName,company.Email,company.companyName, company.CompanyId, processStart, isSucceed,"http get " & httpResult.responseHeader.Status_Code, getTickCount()-start);
						
					}else{
						isSucceed = 1;
						addDebugLog(methodName,"CONFIRMED Email: "& company.companyName, company.Email, company.companyName,company.companyId, processStart, isSucceed,"http get " & httpResult.responseHeader.Status_Code, getTickCount()-start);
					}
				}
			}else if(StructKeyExists(httpResult,"status_code")){
					addDebugLog(methodName,"CONFIRMATION failed for: "& company.companyName,company.Email,company.companyName, company.CompanyId, processStart, isSucceed,"http get " & httpResult.status_code, getTickCount()-start);
			}

			addInfoLog(methodName,"START: validating email adress for " & companyName);
			return;
	}
	/**
	* Confirm newly created worker/user in free msa
	*
	* [section: Application]
	* [category: Utils]
	*
	* @user User to confirm. (required field)
	*/
	private boolean function completeEmployeeRegistration(required struct user){
		var methodName = "completeEmployeeRegistration()";
		var processStart = now();
		var isSucceed = 0;

		addInfoLog(methodName,"START registering user: " & user.Email);

		addDebugLog(methodName,"REGISTER Employee: "& user.Email,user.Email,user.companyName, user.companyId, processStart, 0,"http post", 0);
		
		var start = getTickCount();
		var confirmed = false;
		cfhttp(method="post", charset="utf-8", url="#get('baseURL')#/employee-register?", result="httpResult") {
			cfhttpparam(type="formfield", name="companyName", value=user.CompanyName);
			cfhttpparam(type="formfield", name="firstname", value=user.FirstName);
			cfhttpparam(type="formfield", name="lastname", value=user.LastName); 
			cfhttpparam(type="formfield", name="email", value=user.Email);
			cfhttpparam(type="formfield", name="password", value=user.Password);
			cfhttpparam(type="formfield", name="password-confirm", value=user.Password);
			cfhttpparam(type="formfield", name="phone", value=ToString(user.Phone));
			cfhttpparam(type="formfield", name="companyId", value=user.guid);
		}

		if(StructKeyExists(httpResult, "responseHeader")){
			if(StructKeyExists(httpResult.responseHeader, "Status_Code" )){
				if (httpResult.responseHeader.Status_Code == "302"){
						addInfoLog(methodName,serialize(httpResult));
						var location = ToString(decodeFromURL(httpResult.responseHeader.location));
						addDebugLog(methodName,"REGISTRATION Failed: " & right(location,40), user.Email, user.companyName, user.companyId, processStart, -1,"http post " & httpResult.responseHeader.Status_Code, getTickCount()-start);					
					}else if (httpResult.responseHeader.Status_Code != "200") {
					addErrorLog(methodName,"http post returned with the status code -- " & httpResult.responseHeader.Status_Code,user.Email, user.companyName, user.companyId);

					addDebugLog(methodName,"REGISTRATION failed for "& user.companyName, user.Email, user.companyName, user.companyId, processStart, -1,"http post: "& httpResult.responseHeader.Status_Code, getTickCount()-start); 
				}else{

					addDebugLog(methodName,"REGISTRATION Complete for: "& user.Email, user.Email, user.companyName, user.companyId, processStart, 1,"http post " & httpResult.responseHeader.Status_Code, getTickCount()-start);
					confirmed = true;
				}
			}
		}else if(StructKeyExists(httpResult,"status_code")){
			addDebugLog(methodName,"REGISTRATION failed for "& user.companyName, user.Email, user.companyName, user.companyId, processStart, -1,"http post: "& httpResult.status_code, getTickCount()-start); 
		}

		addInfoLog(methodName,"END: registering " & user.Email);

		return confirmed;
		   // renderWith(httpResult);
	}

	/**
	* Update Log messages of that company with company id.
	*
	* [section: Application]
	* [category: Utils]
	*
	* @companyName Company name which has to be updated. (required field)
	*/
	private boolean function updateCompanyIdInLog(required string companyName){
		
		var methodName = "updateCompanyIdInLog()";

		addInfoLog(methodName, "START Updating: " & companyName);

		var company = model("registration").findOne(where ="companyName = '" & companyName &"'",returnAS = "objects", reload=true); 

		//renderWith(company);
		
		addInfoLog(methodName, "READ: data from db for: " & company.companyName & " id "& company.companyId);
		//updating company id
		if(company.companyId != -1){
			model("msaTesterLog").updateLogTableCompanyId(company.companyId,company.companyName);
			return true;
			addInfoLog(methodName, "UPDATE_DB: from db for: " & company.companyName & " id "& company.companyId);
		}
		addInfoLog(methodName, "END Updating: " & companyName);
		return false;
	}

	/**
	* Create invited user in the database.
	*
	* [section: Application]
	* [category: Utils]
	*
	* @user User which has to store in db. (required field)
	*/
	private void function saveUserInRegistrationTable(required struct user){
		var methodName = "saveUserInRegistrationTable()";

		addInfoLog(methodName, "START inserting: " & user.email);

		var newUser = model("registration").new();
		newUser.guid = user.guid;
		newUser.firstname = user.firstname;
		newUser.lastname = user.lastname;
		newUser.email = user.email;
		newUser.password = "B5A6328CC0BCC3C115E3D9E917811EA61F955855CCE9F1B7A4F7C91D24BA20B732E22371CD36FFB69EC914EA3D9E716AE7C55CBE92F4CF1A8E593C8C0B82280Ds";
		newUser.salt ="611CC2D1D518039E2A2E9811938A746E1B62B3AC9EA5BC0C54AC51C49F532E72B651EF50E985D22ADAE7BCF18AA1145A308BB09C267EC10ABCEA32DF4DD72183";;
		newUser.companyName = user.CompanyName;
		newUser.companySize = user.CompanySize;
		newUser.companyId = user.CompanyId;
		newUser.phone = user.phone;
		newUser.status = 0;

		if(!newUser.save(reload=true)){
			message = newUser.allErrors()[1];
			throw(serialize(message));
		}
		addInfoLog(methodName, "END inserting: " & user.email);
		return;
	}

	/**
	* Get company size from size string.
	*
	* [section: Application]
	* [category: Utils]
	*
	* @sizeStr Company size in string. (required field)
	*/
	private numeric function getCompanySize(string sizeStr) {
		var size = 0;
		if(sizeStr == "1 to 10 employees"){
			size = 1;
		}else if(sizeStr == "11 to 50 employees"){
			size = 11; 
		}else if(sizeStr == "51 to 100 employees"){
			size = 51;
		}else if(sizeStr == "More than 100 employees"){
			size = 100;
		}
		return size;
	}

	/**
	* Get company size in string from size.
	*
	* [section: Application]
	* [category: Utils]
	*
	* @size Company size. (required field)
	*/
	private string function getCompanySizeInString(numeric size) {
		var sizeStr = "";
		if(size == 1 ){
			sizeStr = "1 to 10 employees";
		}else if(size == 11){
			sizeStr = "11 to 50 employees"; 
		}else if(size == 51){
			sizeStr = "51 to 100 employees";
		}else if(size == 100){
			sizeStr = "More than 100 employees";
		}
		return sizeStr;
	}

}