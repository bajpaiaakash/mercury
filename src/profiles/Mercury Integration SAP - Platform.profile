<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <custom>true</custom>
    <description>This profile controls permissions for the integration account utilized by Informatica On Demand &amp; the Invoice-to-SAP integration</description>
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
    <userLicense>Salesforce Platform</userLicense>
    </Profile>
