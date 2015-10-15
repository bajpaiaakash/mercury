<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>MERC_Primary Affiliation Addresses</fullName>
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
        <active>false</active>
        <description>Triggers copying the HCO Primary Address fields to the Primary Affiliate Address fields
 : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISNEW() &amp;&amp; Priority_Rank_Nbr_GLBL__c = 1 ||  (Priority_Rank_Nbr_GLBL__c = 1 &amp;&amp;   (   ISCHANGED(Account_Cust_Id_GLBL__c) ||   ISCHANGED(Account_GLBL__c)  ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
