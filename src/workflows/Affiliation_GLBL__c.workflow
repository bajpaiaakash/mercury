<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_Affiliation_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-Affiliation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prim_Affil_Add_Ln1_GLBL</fullName>
        <description>Within Account object copies the Address from the Affiliate to the the Primary Affiliate Address 
Created by John A Adams 12/12/2013</description>
        <field>Prim_Affil_Addr_Line1_GLBL__c</field>
        <formula>Account_Cust_Id_GLBL__r.Primary_Addr_Line1_GLBL__c</formula>
        <name>Prim Affiliate Add Line 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prim_Affil_Add_Ln2_GLBL</fullName>
        <description>Within Account object copies the Address from the Affiliate to the the Primary Affiliate Address 
Created by John A Adams 12/12/2013</description>
        <field>Prim_Affil_Addr_Line2_GLBL__c</field>
        <formula>Account_Cust_Id_GLBL__r.Primary_Addr_Line2_GLBL__c</formula>
        <name>Prim Affiliate Add Line 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prim_Affil_Postal_GLBL</fullName>
        <description>Copies the Address from to Affiliate to the the Primary Affiliate Address in Accounts.
Created by John A Adams 12/11/2013</description>
        <field>Prim_Affil_Pstl_Cd_Extnsn_GLBL__c</field>
        <formula>Account_Cust_Id_GLBL__r.Primary_Pstl_Cd_Extnsn_GLBL__c</formula>
        <name>Prim Affiliate Postal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prim_Affiliate_City_GLBL</fullName>
        <description>Within Account object copies the Address from the Affiliate to the the Primary Affiliate Address 
Created by John A Adams 12/12/2013</description>
        <field>Prim_Affil_Addr_City_GLBL__c</field>
        <formula>Account_Cust_Id_GLBL__r.Primary_Addr_City_GLBL__c</formula>
        <name>Prim Affiliate City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prim_Affiliate_Country_GLBL</fullName>
        <description>Within Account object copies the Address from the Affiliate to the the Primary Affiliate Address 
Created by John A Adams 12/12/2013</description>
        <field>Prim_Affil_Addr_Country_GLBL__c</field>
        <formula>Account_Cust_Id_GLBL__r.Primary_Address_Country_GLBL__c</formula>
        <name>Prim Affiliate Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prim_Affiliate_HCO_GLBL</fullName>
        <description>Copies the HCO from to Affiliate to the the Primary Affiliate HCO in Accounts 
Created by John A Adams 12/11/2013</description>
        <field>Primary_HCO_GLBL__c</field>
        <formula>Account_Cust_Id_GLBL__r.Id</formula>
        <name>Prim Affiliate HCO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prim_Affiliate_HCO_Name_GLBL</fullName>
        <description>Copies the HCO Name from to Affiliate to the the Primary Affiliate HCO Name in Accounts 
Created by John A Adams 12/11/2013</description>
        <field>Prim_Affil_HCO_GLBL__c</field>
        <formula>Account_Cust_Id_GLBL__r.Name</formula>
        <name>Prim Affiliate HCO Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Mercury External ID-Affiliation_MERC</fullName>
        <actions>
            <name>External_ID_Affiliation_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Affiliation_GLBL__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Primary Affiliation Addresses_MERC</fullName>
        <actions>
            <name>Prim_Affil_Add_Ln1_GLBL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Prim_Affil_Add_Ln2_GLBL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Prim_Affil_Postal_GLBL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Prim_Affiliate_City_GLBL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Prim_Affiliate_Country_GLBL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Prim_Affiliate_HCO_GLBL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Prim_Affiliate_HCO_Name_GLBL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Affiliation_GLBL__c.Priority_Rank_Nbr_GLBL__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Triggers copying the HCO Primary Address fields to the Primary Affiliate Address fields
Created by John A Adams 12/12/2013</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
