<cfcomponent output="false">
	<cffunction name="init" access="public" output="false">
		<cfscript>
		// Create Java Objects from xmlsec and wss4j
		variables.WSConstantsObj = CreateObject("Java","org.apache.ws.security.WSConstants");
		variables.messageClass = CreateObject("Java","org.apache.ws.security.message.WSSecUsernameToken");
		variables.secHeaderClass = CreateObject("Java","org.apache.ws.security.message.WSSecHeader");
		return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="getMessage" access="private" output="false">
		<cfscript>
		if (!structKeyExists(variables,"messagePkg")){
			init();
		}	
		return variables.messageClass.Init();
		</cfscript>
	</cffunction>
	
	<cffunction name="getSecHeader" access="private" output="false">
		<cfscript>
		if (!structKeyExists(variables,"messagePkg")){
			init();
		}	
		return variables.secHeaderClass.Init();
		</cfscript>
	</cffunction>
	
	<cffunction name="getWSConstants" access="private" output="false">
		<cfscript>
		if (!structKeyExists(variables,"WSConstantsObj")){
			init();
		}	
		return variables.WSConstantsObj;
		</cfscript>
	</cffunction>	
	
	<cffunction name="addWSAuthentication"  access="public" output="true" hint="I sign SOAP envelope using WS Authentication">
		<cfargument name="soapEnvelope" type="string" required="true">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="false">
		<cfargument name="passwordType" type="string" required="false" default="text" hint="Text or Digest">
		<cfscript>
		// Get Soap Envlope document for Java processing
		var msg = getMessage();
		var secHeader = getSecHeader();
		var WSConstants = getWSConstants();
		var soapEnv = arguments.soapEnvelope;
		var env = soapEnv.getDocumentElement(); 
		var e = "";
		
		switch(arguments.passwordType){
			case "text":
				// Set Password type to TEXT (if not declared, default is DIGEST)
				msg.setPasswordType(WSConstants.PASSWORD_TEXT);
			break;
		}
		
		// Create WS-Security SOAP header using the build method from WSSecUsernameToken
		msg.setUserInfo(arguments.username,arguments.password);
		msg.addNonce();
		msg.addCreated();
		secHeader.insertSecurityHeader(env.GetOwnerDocument());
		e = msg.build(env.GetOwnerDocument(),secHeader);
		
		return soapEnv;
		</cfscript>
	</cffunction>
	
	<cffunction name="sendSoapRequest" access="public" output="false" hint="I send the SOAP request off retrun the SOAP response">
		<cfargument name="endpoint" type="string" required="true">
		<cfargument name="soapEnvelope" type="any" required="true">
		<cfargument name="soapAction" type="string" required="false" default="">
		<cfset var result = "">
		<cfset var soapEnv = "">
		
		<cfhttp url="#arguments.endpoint#" method="POST" result="result" >
			<cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0">
			<cfhttpparam type="Header" name="TE" value="deflate;q=0"> 
			<cfhttpparam type="header" name="SOAPAction" value="""#arguments.soapAction#""">
			<cfhttpparam type="xml" value="#toString(xmlParse(arguments.soapEnvelope))#"/>
		</cfhttp>
		
		<cfreturn result.fileContent>		
	</cffunction>

</cfcomponent>