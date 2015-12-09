<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Set_Consent_External_Key</fullName>
        <description>Sets the Consent External Key : MERC : Created on 20/08/2014 by Oliver Dunford, Mavens Consulting</description>
        <field>Party_Cnsnt_External_ID_GLBL__c</field>
        <formula>IF(($Profile.Name = &apos;GSO Basic User_Platform&apos; || $Profile.Name = &apos;GSO Basic User_Salesforce&apos; || $Profile.Name = &apos;System Administrator&apos;), 
	Account_GLBL__r.Cust_Id_GLBL__c &amp; 
	Account_GLBL__r.Party_Rcrd_Typ_Cd_GLBL__c &amp; 
	TEXT(Cmnctn_Chnl_Cd_CMS_MERC__c) &amp; 
	&quot;EXPMKTG&quot;,
IF($Profile.Name = &apos;Mercury Integration ODS - Platform&apos;, 
	 Party_Cnsnt_External_ID_GLBL__c ,
IF(($Profile.Name = &apos;Mercury Metadata API&apos; || $Profile.Name = &apos;Mercury Portal API - Platform&apos; || $Profile.Name = &apos;Mercury Integration CST - Platform&apos;), 
	Account_GLBL__r.Cust_Id_GLBL__c &amp; 
	Account_GLBL__r.Party_Rcrd_Typ_Cd_GLBL__c &amp; 
	Cmnctn_Chnl_Cd_Cap_GLBL__c &amp; 
	Cnsnt_Typ_Cd_Cap_GLBL__c &amp;
        Cnsnt_Prps_Cd_Cap_GLBL__c 
,&quot;&quot;)))</formula>
        <name>MERC_Set Consent External Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
