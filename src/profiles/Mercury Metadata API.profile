<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <custom>true</custom>
    <description>For a portal background task that queries the Salesforce Metadata API. SFDC requires the User accessing the Metadata API must have the &quot;Modify All Data&quot; Permission (only available with a full SF license) Created 03/28/2014 by KLorenti, Mavens Consulting</description>
    <fieldPermissions>
        <editable>true</editable>
        <field>Account.Primary_Address_County_GLBL__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>User.CST_Admin_CUST__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <layoutAssignments>
        <layout>User-User Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>UserAlt-User Profile Layout</layout>
    </layoutAssignments>
    <userLicense>Salesforce</userLicense>
    </Profile>
