<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>GLBL_Prim_Affiliate_Add_Line_1</fullName>
        <field>Prim_Affil_Addr_Line1_GLBL__c</field>
        <name>GLBL Prim Affiliate Add Line 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>GLBL_Prim_Affiliate_Add_Line_2</fullName>
        <field>Prim_Affil_Addr_Line2_GLBL__c</field>
        <name>GLBL Prim Affiliate Add Line 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>GLBL_Prim_Affiliate_City</fullName>
        <field>Prim_Affil_Addr_City_GLBL__c</field>
        <name>GLBL Prim Affiliate City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>GLBL_Prim_Affiliate_Country</fullName>
        <field>Prim_Affil_Addr_Country_GLBL__c</field>
        <name>GLBL Prim Affiliate Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>GLBL_Prim_Affiliate_HCO</fullName>
        <field>Primary_HCO_GLBL__c</field>
        <name>GLBL Prim Affiliate HCO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>GLBL_Prim_Affiliate_HCO_Name</fullName>
        <field>Prim_Affil_HCO_GLBL__c</field>
        <name>GLBL Prim Affiliate HCO Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>GLBL_Prim_Affiliate_Postal</fullName>
        <field>Prim_Affil_Pstl_Cd_Extnsn_GLBL__c</field>
        <name>GLBL Prim Affiliate Postal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>GLBL_clear_Primary_Aff_Fields</fullName>
        <actions>
            <name>GLBL_Prim_Affiliate_Add_Line_1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>GLBL_Prim_Affiliate_Add_Line_2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>GLBL_Prim_Affiliate_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>GLBL_Prim_Affiliate_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>GLBL_Prim_Affiliate_HCO</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>GLBL_Prim_Affiliate_HCO_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>GLBL_Prim_Affiliate_Postal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To Clear out fields when end date is less than or equal to today or Source block flag is equal to Yes.</description>
        <formula>(Efctv_End_Dt_GLBL__c  &lt;= TODAY()  ||  UPPER(Src_Block_Flg_GLBL__c)  =  &apos;Y&apos; )&amp;&amp;( UPPER(Party_Rcrd_Typ_Cd_GLBL__c) = &apos;HCP&apos; || UPPER(Party_Rcrd_Typ_Cd_GLBL__c) = &apos;HCO&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
