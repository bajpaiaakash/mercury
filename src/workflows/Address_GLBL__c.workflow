<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Prim_Add_County</fullName>
        <description>Stamps County Name into Primary Address on Account.</description>
        <field>Primary_Address_County_GLBL__c</field>
        <formula>Cnty_Nm_GLBL__c</formula>
        <name>Prim Add County</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Primary Address</fullName>
        <actions>
            <name>Prim_Add_City_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Prim_Add_Country_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Prim_Add_County</name>
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
        <actions>
            <name>Prim_Add_State</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Triggers copying the Address  fields to the Primary Address Fields in Accounts : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting
Created by John A Adams 12/13/2013</description>
        <formula>ISNEW() &amp;&amp; Priority_Rank_Nbr_GLBL__c = 1 &amp;&amp; RecordType.Name  = &quot;Mastered Address&quot; ||   ( 	Priority_Rank_Nbr_GLBL__c = 1 &amp;&amp;  RecordType.Name = &quot;Mastered Address&quot; &amp;&amp;   		(    			(ISCHANGED(Line_1_Adrs_Txt_GLBL__c )) ||    			(ISCHANGED(Line_2_Adrs_Txt_GLBL__c )) ||   			(ISCHANGED(Line_3_Adrs_Txt_GLBL__c )) ||  			(ISCHANGED(Line_4_Adrs_Txt_GLBL__c )) ||    			(ISCHANGED(City_GLBL__c )) ||                            (ISCHANGED(St_Cd_GLBL__c )) ||(ISCHANGED(Cnty_Nm_GLBL__c 			))||(ISCHANGED(Adrs_Cntry_Cd_GLBL__c )) ||   			(ISCHANGED(Zip_Postal_Code_GLBL__c )) || 			(ISCHANGED(RecordTypeId))    		)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
