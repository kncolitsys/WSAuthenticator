<cffunction name="getSoapEnvelope" output="false" access="public">
	<cfset var soapEnvelope = "">
	<cfxml variable="soapEnvelope">
	<SOAP-ENV:Envelope
	   xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
	   SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"> 
	   <SOAP-ENV:Body>
	      <m:OrderItem xmlns:m="Some-URI">
	      <RetailerID>123456</RetailerID>
	      <ItemNumber>789</ItemNumber>
	      <ItemName>Really Cool Item</ItemName>
	      <ItemDesc>This item is the coolest</ItemDesc>
	      <OrderQuantity>100</OrderQuantity>
	      <WholesalePrice>14.99</WholesalePrice>
	      <OrderDateTime><cfoutput>#dateFormat(now(),"MM/DD/yyyy")# #timeFormat(now(),"HH:DD TT")#</cfoutput></OrderDateTime>
	      </m:OrderItem>
	   </SOAP-ENV:Body>  
	</SOAP-ENV:Envelope>	
	</cfxml>
	<cfreturn soapEnvelope>
</cffunction>

<h1>Soap Envelope Before Signing</h1>
<cfset soapEnvelope = getSoapEnvelope()>
<cfdump var="#toString(soapEnvelope)#">
<cfdump var="#soapEnvelope#">


<!--- Make sure the JAR files are loaded! If you dropped them in [cf home]/lib, you must restart ColdFusion --->
<cfset wsAuth = createObject("component","cfWSAuthenticator.src.WSAuthenticator").init()>

<h1>Soap Envelope After Signing (Plain Text)</h1>
<cfset signedSOAPEnvelope = wsAuth.addWSAuthentication(soapEnvelope,"YourUsername","YourPassword")>
<cfdump var="#toString(signedSOAPEnvelope)#">
<cfdump var="#signedSOAPEnvelope#">

<cfset soapEnvelope = getSoapEnvelope()>
<h1>Soap Envelope After Signing (Digest)</h1>
<cfset signedSOAPEnvelope = wsAuth.addWSAuthentication(soapEnvelope,"YourUsername","YourPassword","digest")>
<cfdump var="#toString(signedSOAPEnvelope)#">
<cfdump var="#signedSOAPEnvelope#">

<!--- 
To Send the Signed envelope 
<cfset response = wsAuth.sendSoapRequest("endpointURLForWebService",signedSOAPEnvelope,"theSoapAction")>

sendSoapRequest could be removed from the object and placed into its own object elsewhere. 
It's in the object as a conveniene since it adds the required headers for WS Security.
--->