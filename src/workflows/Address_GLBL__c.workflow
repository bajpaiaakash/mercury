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
    <fieldUpdates>
        <fullName>Update_Address_Account_Name_MERC</fullName>
        <description>Updates the Address Account Name.</description>
        <field>Account_Name_MERC__c</field>
        <formula>Account_GLBL__r.FirstName &amp; &quot; &quot; &amp; Account_GLBL__r.LastName</formula>
        <name>Update Address Account Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Mercury External ID-Address_MERC</fullName>
        <actions>
            <name>External_ID_Address_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Address_GLBL__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Primary Address_MERC</fullName>
        <actions>
            <name>Prim_Add_City_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Prim_Add_Country_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Prim_Add_Line1_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Prim_Add_Line2_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Prim_Add_Postal_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Triggers copying the Address  fields to the Primary Address Fields in Accounts
Created by John A Adams 12/13/2013</description>
        <formula>ISNEW() &amp;&amp; Priority_Rank_Nbr_GLBL__c = 1 &amp;&amp; RecordType.Name  = &quot;Mastered Address&quot; || 
(Priority_Rank_Nbr_GLBL__c = 1 &amp;&amp;  RecordType.Name = &quot;Mastered Address&quot; &amp;&amp;
 (
  (ISCHANGED(Line_1_Adrs_Txt_GLBL__c )) ||
  (ISCHANGED(Line_2_Adrs_Txt_GLBL__c )) ||
  (ISCHANGED(Line_3_Adrs_Txt_GLBL__c )) ||
  (ISCHANGED(Line_4_Adrs_Txt_GLBL__c )) ||
  (ISCHANGED(City_GLBL__c )) ||
  (ISCHANGED(Adrs_Cntry_Cd_GLBL__c )) ||
  (ISCHANGED(Zip_Postal_Code_GLBL__c )) 
 )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Address Account Name_MERC</fullName>
        <actions>
            <name>Update_Address_Account_Name_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Address Account Name to ensure this can be used in Lookup relationship Searches.  Field must remain on Address layout. Oliver Dunford 22nd Jan 2014.</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
