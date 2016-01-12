<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>CUST_User Settings Under Review</fullName>
        <actions>
            <name>Update_Manager_CUST</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>User_Settings_Will_Expire_CUST</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>CST_User_Settings_CUST__c.Audit_Date_CUST__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>Update the manager of any record under review : CUST : Created on 12/5/2013 by Sam Rosen, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
