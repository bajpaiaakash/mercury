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
        <fullName>Other_Amount</fullName>
        <description>Calculates Amount value for Other Items</description>
        <field>Amount_MERC__c</field>
        <formula>Quantity_MERC__c *  Unit_Price_MERC__c</formula>
        <name>Other Amount</name>
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
    <fieldUpdates>
        <fullName>Update_Amount_for_AdHoc_MERC</fullName>
        <description>Updates the Amount field rolled up to the Invoice Totals with the value manually typed by HCP Care for the Ad Hoc consulting Invoices. Oliver Dunford 13th Dec 2013.</description>
        <field>Amount_MERC__c</field>
        <formula>Consulting_Amount_MERC__c</formula>
        <name>Update Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_External ID-InvoiceLine</fullName>
        <actions>
            <name>External_ID_InvoiceLine_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Populate Ad Hoc Amount</fullName>
        <actions>
            <name>Update_Amount_for_AdHoc_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate Line Item amount for Consulting Projects : MERC : Created on 01/26/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>AND (NOT(ISBLANK( Invoice_MERC__r.Meeting_Participant_MERC__c)), RecordType.Name = &apos;Consulting Project&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Populate Other Amounts</fullName>
        <actions>
            <name>Other_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Calculates the Amount for other Line Item entries : MERC : Created on 01/26/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>AND (NOT(ISBLANK( Invoice_MERC__r.Meeting_Participant_MERC__c)), RecordType.Name = &apos;Other Items&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Populate Service Amount</fullName>
        <actions>
            <name>Service_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate Line Item amount for Services : MERC : Created on 01/26/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>AND (NOT(ISBLANK( Invoice_MERC__r.Meeting_Participant_MERC__c)),  RecordType.Name = &apos;Contracted Services&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
