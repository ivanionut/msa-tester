component extends="Controller" {

	public void function config() {
		//super.config();

		provides("json");
	}


	public void function startRegister() {
		var input = 2;
		var processTime = now();

		addLogLine("INFO", "startRegister()"," Start to create users "& input);
		
		var userList = queryToStructs(model("User").generateRandomUsersForFreeMsa(input));
		
		addLogLine("INFO", "startRegister()","Returns " & userList.len() & " user profiles");

		for (var i=1; i <= userList.len(); i++) {
			
			userList[i].Password = "test123";
			
			var randNum = RandRange(1, 1000);
			userList[i].CompanyName = userList[i].LastName & " And Brothers " & randNum;
			
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
		
		for (var i=1; i<= userList.len();i++) {
			
			addLogLine("INFO", "startRegister()"," For registration calling http post for "& userList[i].companyName,"",userList[i].companyName, userList[i].companySize, processTime,0, dateDiff("s", processTime, now())*1000);
			
			cfhttp(method="post", charset="utf-8", url="#get('baseURL')#/company-register", result="httpResult") {

	            cfhttpparam(type="formfield", name="firstname", value=userList[i].FirstName);
	            cfhttpparam(type="formfield", name="lastname", value=userList[i].LastName); 
	            cfhttpparam(type="formfield", name="email", value=userList[i].Email);
	            cfhttpparam(type="formfield", name="password", value=userList[i].Password);
	            cfhttpparam(type="formfield", name="password-confirm", value=userList[i].Password);
	            cfhttpparam(type="formfield", name="companyName", value=userList[i].CompanyName);
	            cfhttpparam(type="formfield", name="phone", value=ToString(userList[i].Phone));
	            cfhttpparam(type="formfield", name="size", value=userList[i].CompanySize);
	        }

	        if (httpResult.responseHeader.Status_Code != "200") {
	        	addLogLine("ERROR", "startRegister()"," registration does not completed for "& userList[i].companyName,"Fatal",userList[i].companyName, userList[i].companySize, processTime, 0,dateDiff("s", processTime, now())*1000);
	        	renderWith(httpResult.errorDetail);
	        }else{
	        		addLogLine("INFO", "startRegister()"," registration completed for "& userList[i].companyName,"",userList[i].companyName, userList[i].companySize, processTime, 1,dateDiff("s", processTime, now())*1000);
	        }

	        startConfirmingEmail(userList[i].CompanyName);
          	 renderWith(httpResult);

        }

		return;
	}

	private void function startConfirmingEmail(required string companyName){
		var processTime = now();
		
		addLogLine("INFO", "startConfirmingEmail()","start validating email adress for "& companyName,"",companyName, 1, processTime, 0, 0);
		
		var company = model("registration").findOne(where ="companyName = '" & companyName &"'",returnAS = "objects"); 
		
		var companySize = getCompanySize(company.companySize);
		
		addLogLine("INFO", "startConfirmingEmail()"," retrieved company from db "& companyName,"", company.email, companySize, processTime,0, dateDiff("s", processTime, now())*1000);

		cfhttp(method="GET", charset="utf-8", url="#get('baseURL')#/company-confirm?", result="httpResult") {
            cfhttpparam(type="url", name="key", value="#company.guid#");
        }
         if (httpResult.responseHeader.Status_Code != "200") {
         	addLogLine("ERROR", "startConfirmingEmail()"," email validation failed for "& companyName,"FATAL", company.email,companyName, companySize, processTime, 0 ,dateDiff("s", processTime, now())*1000);
         }else{
         	addLogLine("INFO", "startConfirmingEmail()"," email validation done for "& companyName,"",company.email, companySize, processTime, 1, dateDiff("s", processTime, now())*1000);
         }
        renderWith(httpResult);
	}

	
	public numeric function getCompanySize(string sizeStr) {
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
}