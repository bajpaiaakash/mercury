<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_Address_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prim_Add_City_MERC</fullName>
        <description>Stamps City Name in Primary Address City of Accounts
Created by John A Adams 12/11/2013</description>
        <field>Primary_Addr_City_GLBL__c</field>
        <formula>City_GLBL__c</formula>
        <name>Prim Add City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prim_Add_Country_MERC</fullName>
        <description>Stamps Address Country in Primary Address Country of Accounts
Created by John A Adams 12/11/2013</description>
        <field>Primary_Address_Country_GLBL__c</field>
        <formula>TEXT(Adrs_Cntry_Cd_GLBL__c)</formula>
        <name>Prim Add Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prim_Add_Line1_MERC</fullName>
        <description>Stamps Address Line 1 in Primary Address Line 1 of Accounts
Created by John A Adams 12/11/2013</description>
        <field>Primary_Addr_Line1_GLBL__c</field>
        <formula>Line_1_Adrs_Txt_GLBL__c</formula>
        <name>Prim Add Line1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prim_Add_Line2_MERC</fullName>
        <description>Stamps Address Line 2 in Primary Address Line 2 of Accounts
Created by John A Adams 12/11/2013</description>
        <field>Primary_Addr_Line2_GLBL__c</field>
        <formula>Line_2_Adrs_Txt_GLBL__c</formula>
        <name>Prim Add Line2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prim_Add_Postal_MERC</fullName>
        <description>Stamps Address Postal Code into Primary Postal Code Extension of Accounts
Created by John A Adams 12/11/2013</description>
        <field>Primary_Pstl_Cd_Extnsn_GLBL__c</field>
        <formula>Zip_Postal_Code_GLBL__c</formula>
        <name>Prim Add Postal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Mercury External ID-Address</fullName>
        <actions>
            <name>External_ID_Address_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Address_GLBL__c.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Prim Add City</fullName>
        <actions>
            <name>Prim_Add_City_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Address_GLBL__c.Priority_Rank_Nbr_GLBL__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Triggers copying the Address City to the Primary Address City of Accounts
Created by John A Adams 12/11/2013</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prim Add Country</fullName>
        <actions>
            <name>Prim_Add_Country_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Address_GLBL__c.Priority_Rank_Nbr_GLBL__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Triggers copying the Address Country Code to the Primary Address Country of Accounts
Created by John A Adams 12/11/2013</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prim Add Line1</fullName>
        <actions>
            <name>Prim_Add_Line1_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Address_GLBL__c.Priority_Rank_Nbr_GLBL__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Triggers copying the Address Line 1 to the Primary Address Line 1 of Accounts
Created by John A Adams 12/11/2013</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prim Add Line2</fullName>
        <actions>
            <name>Prim_Add_Line2_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Address_GLBL__c.Priority_Rank_Nbr_GLBL__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Triggers copying the Address Line 2 to the Primary Address Line 2 of Accounts
Created by John A Adams 12/11/2013</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prim Add Postal</fullName>
        <actions>
            <name>Prim_Add_Postal_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Address_GLBL__c.Priority_Rank_Nbr_GLBL__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Triggers copying the Address Postal Code to the Primary Postal Code Extension of Accounts
Created by John A Adams 12/11/2013</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
