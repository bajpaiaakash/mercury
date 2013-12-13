<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_InvoiceLine_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-InvoiceLine</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Other_Amounts</fullName>
        <description>Calculates line Item Other Amount</description>
        <field>Amount_MERC__c</field>
        <formula>Quantity_MERC__c *  Unit_Price_MERC__c</formula>
        <name>Other Amounts</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Service_Amount</fullName>
        <description>Calculates line Item Service Amount</description>
        <field>Amount_MERC__c</field>
        <formula>Invoice_MERC__r.Meeting_Participant_MERC__r.Final_Fee_MERC__c</formula>
        <name>Service Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Mercury External ID-InvoiceLine</fullName>
        <actions>
            <name>External_ID_InvoiceLine_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice_Line_Item_MERC__c.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Other Amounts_MERC</fullName>
        <actions>
            <name>Other_Amounts</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice_Line_Item_MERC__c.Quantity_MERC__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>Calculates the Amount for other Line Item entries</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Service Amount_MERC</fullName>
        <actions>
            <name>Service_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate Line Item amount for Services
Created by John A Adams 10/31/2013</description>
        <formula>NOT(ISBLANK( Invoice_MERC__r.Meeting_Participant_MERC__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
