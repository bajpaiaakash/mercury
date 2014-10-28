<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_Invoice_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-Invoice</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Stamp_Internal_Order_Number</fullName>
        <description>Stamp Internal Order Number : MERC : Created on 01/26/2013 by Katy Lorenti, Mavens Consulting</description>
        <field>Internal_Order_Number_MERC__c</field>
        <formula>Meeting_Participant_MERC__r.Meeting_MERC__r.Internal_Order_Number_MERC__c</formula>
        <name>MERC_Stamp Internal Order Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Bank_Account_Number</fullName>
        <description>Populates the Bank Account Number from Payee</description>
        <field>Bank_Account_Number_MERC__c</field>
        <formula>Payee_MERC__r.Bank_Account_Number_MERC__c</formula>
        <name>Populate Bank Account Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Bank_City</fullName>
        <description>Populates the Bank City from Payee</description>
        <field>Bank_City_MERC__c</field>
        <formula>Payee_MERC__r.Bank_City_MERC__c</formula>
        <name>Populate Bank City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Bank_Country</fullName>
        <description>Populates the Bank Country from Payee</description>
        <field>Bank_Country_MERC__c</field>
        <formula>Payee_MERC__r.Bank_Country_MERC__c</formula>
        <name>Populate Bank Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Bank_Name</fullName>
        <description>Populates the Bank Name from Payee</description>
        <field>Bank_Name_MERC__c</field>
        <formula>Payee_MERC__r.Bank_Name_MERC__c</formula>
        <name>Populate Bank Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Bank_State_Province</fullName>
        <description>Populates the Bank State / Province  from Payee</description>
        <field>Bank_State_Province_MERC__c</field>
        <formula>Payee_MERC__r.Bank_State_Province_MERC__c</formula>
        <name>Populate Bank State / Province</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Bank_Street</fullName>
        <description>Populates the Bank Street from Payee</description>
        <field>Bank_Street_MERC__c</field>
        <formula>Payee_MERC__r.Bank_Street_MERC__c</formula>
        <name>Populate Bank Street</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Bank_Zip</fullName>
        <description>Populates the Bank Zip / Postal from Payee</description>
        <field>Bank_Zip_Postal_Code_MERC__c</field>
        <formula>Payee_MERC__r.Bank_Zip_Postal_Code_MERC__c</formula>
        <name>Populate Bank Zip</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_IBAN</fullName>
        <description>Populates the IBAN from Payee</description>
        <field>IBAN_MERC__c</field>
        <formula>Payee_MERC__r.Bank_IBAN_MERC__c</formula>
        <name>Populate IBAN</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Payee_City</fullName>
        <description>Populates the Payee City from Payee</description>
        <field>Payee_City_MERC__c</field>
        <formula>Payee_MERC__r.Payee_City_MERC__c</formula>
        <name>Populate Payee City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Payee_Country</fullName>
        <description>Populates the Payee Country from Payee</description>
        <field>Payee_Country_MERC__c</field>
        <formula>Payee_MERC__r.Payee_Country_MERC__c</formula>
        <name>Populate Payee Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Payee_Name</fullName>
        <description>Populates the Payee Name from Payee
Truncates the Payee Name to 35 characters to send via the SAP Interface. This is just used to trouble shoot any issues on the SAP end and is hidden from users view. Oliver Dunford 5th Dec 2013.</description>
        <field>Payee_Name_MERC__c</field>
        <formula>LEFT( Payee_MERC__r.Name , 35)</formula>
        <name>Populate Payee Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Payee_State</fullName>
        <description>Populates the Payee State / Province from Payee</description>
        <field>Payee_State_Province_MERC__c</field>
        <formula>Payee_MERC__r.Payee_State_Province_MERC__c</formula>
        <name>Populate Payee State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Payee_Zip</fullName>
        <description>Populates the Payee Zip from Payee</description>
        <field>Payee_Zip_Postal_Code_MERC__c</field>
        <formula>Payee_MERC__r.Payee_Zip_Postal_Code_MERC__c</formula>
        <name>Populate Payee Zip</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_SAP_Vendor_Id_MERC</fullName>
        <description>Populated SAP Vendor Number if one exists on the Payee Record. Oliver Dunford 20th Jan 2014.</description>
        <field>SAP_Vendor_Number_MERC__c</field>
        <formula>IF(ISBLANK(SAP_Vendor_Number_MERC__c),  Payee_MERC__r.SAP_Vendor_ID_MERC__c , SAP_Vendor_Number_MERC__c)</formula>
        <name>Populate SAP Vendor Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Sort_Code</fullName>
        <description>Populates the Bank SWIFT Code from Payee</description>
        <field>Bank_Sort_Code_MERC__c</field>
        <formula>Payee_MERC__r.Bank_Sort_Code_MERC__c</formula>
        <name>Populate Sort Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Street</fullName>
        <description>Populates the Payee Street from Payee</description>
        <field>Payee_Street_MERC__c</field>
        <formula>Payee_MERC__r.Payee_Street_MERC__c</formula>
        <name>Populate Street</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Tax_Id_MERC</fullName>
        <description>Pulls Tax Id from Payee Record.</description>
        <field>Tax_Id_MERC__c</field>
        <formula>Payee_MERC__r.Tax_Id_MERC__c</formula>
        <name>Populate Tax Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_VAT_ID</fullName>
        <description>Populates the VAT ID from Payee</description>
        <field>VAT_Identification_MERC__c</field>
        <formula>Payee_MERC__r.VAT_ID_MERC__c</formula>
        <name>Populate VAT ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Invoice_Locked_MERC</fullName>
        <description>Sets the record type to locked. Oliver Dunford 28th April 2014.</description>
        <field>RecordTypeId</field>
        <lookupValue>Invoice_Locked_MERC</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Invoice Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Toggle_to_Lock_Credit_Note_MERC</fullName>
        <description>Locks the Credit Note by toggling the record type.  Oliver Dunford 28th April 2014.</description>
        <field>RecordTypeId</field>
        <lookupValue>Credit_Note_Locked_MERC</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Toggle to Lock Credit Note</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_External ID-Invoice</fullName>
        <actions>
            <name>External_ID_Invoice_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record: MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Populate Internal Order Number</fullName>
        <actions>
            <name>MERC_Stamp_Internal_Order_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate Internal Order Number from Meeting.  This field remains read/write for CMS Cork in case an Internal Order Number does not exist : MERC : Created on 24/07/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>(ISNEW() &amp;&amp; !ISBLANK( Meeting_Participant_MERC__r.Meeting_MERC__r.Internal_Order_Number_MERC__c )) || ISCHANGED( Meeting_Participant_MERC__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Populate Invoice Bank information</fullName>
        <actions>
            <name>Populate_Bank_Account_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Bank_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Bank_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Bank_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Bank_State_Province</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Bank_Street</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Bank_Zip</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_IBAN</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Sort_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate Bank information into Invoice : MERC : Created on 01/26/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>(ISNEW() &amp;&amp; !ISBLANK(Payee_MERC__c)) || ISCHANGED(Payee_MERC__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Populate Invoice Payee information</fullName>
        <actions>
            <name>Populate_Payee_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Payee_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Payee_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Payee_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Payee_Zip</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_SAP_Vendor_Id_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Street</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Tax_Id_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_VAT_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate Payee information into Invoice : MERC : Created on 01/26/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>(ISNEW() &amp;&amp; !ISBLANK(Payee_MERC__c)) || ISCHANGED(Payee_MERC__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Toggle to Lock Credit Note</fullName>
        <actions>
            <name>Toggle_to_Lock_Credit_Note_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Toggles Record Types to Locked for Credit Notes that have been submitted for payment : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Submit_for_Payment_MERC__c )  &amp;&amp; TEXT(Submit_for_Payment_MERC__c) = &quot;Yes&quot; &amp;&amp; RecordType.Name = &quot;Credit Note&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Toggle to Lock Invoice</fullName>
        <actions>
            <name>Set_Invoice_Locked_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Toggles Record Types to Locked for Invoices that have been submitted for payment : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Submit_for_Payment_MERC__c )  &amp;&amp; TEXT(Submit_for_Payment_MERC__c) = &quot;Yes&quot; &amp;&amp; RecordType.Name = &quot;Invoice&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
