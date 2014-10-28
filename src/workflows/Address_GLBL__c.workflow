<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Clear_Address_Line_1_MERC</fullName>
        <description>Sets Address Line 1 to Non NCP so that empty addresses can be verified as being due to Non HCPs.  Oliver Dunford 12th May 2014.</description>
        <field>Line_1_Adrs_Txt_GLBL__c</field>
        <formula>&quot;Non HCP Data Anonymised&quot;</formula>
        <name>Clear Address Line 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Address_Line_2_MERC</fullName>
        <description>Clears down Address Line 2.  Anonymise Non HCP Data.  Oliver Dunford 12th May 2014.</description>
        <field>Line_2_Adrs_Txt_GLBL__c</field>
        <name>Clear Address Line 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Address_Line_3_MERC</fullName>
        <description>Clear down Address Line 3.  Non HCP Anonymise Data. Oliver Dunford 12th May 2014.</description>
        <field>Line_3_Adrs_Txt_GLBL__c</field>
        <name>Clear Address Line 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Address_Line_4_MERC</fullName>
        <description>Clears down address line 4.  Non HCP Anonymise Data.  Oliver Dunford 12th May 2014.</description>
        <field>Line_4_Adrs_Txt_GLBL__c</field>
        <name>Clear Address Line 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Down_City_MERC</fullName>
        <description>Clear down City.  Non HCP Anonymise Data Process. Oliver Dunford 12th May 2014.</description>
        <field>City_GLBL__c</field>
        <name>Clear Down City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Down_Country_Code_MERC</fullName>
        <description>Clear Down Country Code.  Oliver Dunford 12th May 2014.</description>
        <field>Adrs_Cntry_Cd_GLBL__c</field>
        <name>Clear Down Country Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Down_Phone_Number_1_MERC</fullName>
        <description>Clears down Phone Number 1. Non HCP Anonymise data process.  Oliver Dunford 12th May 2014.</description>
        <field>Elctrnc_Adrs_Txt_GLBL__c</field>
        <name>Clear Down Phone Number 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Down_Region_MERC</fullName>
        <description>Clear down Region.  Anonymise Non HCP data. Oliver Dunford 12th May 2014.</description>
        <field>St_Cd_GLBL__c</field>
        <name>Clear Down Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Fax_Number_MERC</fullName>
        <description>Clears the Fax Number.  Non HCP Anonymise Data. Oliver Dunford 12th May 2014.</description>
        <field>Elctrnc_Adrs_Fax_Txt_GLBL__c</field>
        <name>Clear Fax Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Zip_Post_Code_MERC</fullName>
        <description>Clear down Zip/Post Code.  Non HCP Anonymise Process. Oliver Dunford May 12th  2014.</description>
        <field>Zip_Postal_Code_GLBL__c</field>
        <name>Clear Zip / Post Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
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
        <fullName>Prim_Add_State</fullName>
        <description>Stamps State/Region Code into Primary Address on Account.</description>
        <field>Primary_St_Cd_GLBL__c</field>
        <formula>TEXT(St_Cd_GLBL__c)</formula>
        <name>Prim Add State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_GLBL__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Global_ID</fullName>
        <description>Stamps Customer ID onto Address</description>
        <field>Account_Global_Id_GLBL__c</field>
        <formula>Account_GLBL__r.Cust_Id_GLBL__c</formula>
        <name>Stamp Global ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
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
        <fullName>MERC_External ID-Address</fullName>
        <actions>
            <name>External_ID_Address_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Address_GLBL__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Non HCP Anonymise Record</fullName>
        <actions>
            <name>Clear_Address_Line_1_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Address_Line_2_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Address_Line_3_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Address_Line_4_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Down_City_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Down_Country_Code_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Down_Phone_Number_1_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Down_Region_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Fax_Number_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Zip_Post_Code_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Address_GLBL__c.Anonymise_Record_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Clears down information about the Non HCP post the closure of the meeting that they attended. This workflow clears down the Address object only. Oliver Dunford 12th May 2014 : MERC : Created on 05/08/2014 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
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
        <formula>ISNEW() &amp;&amp; Priority_Rank_Nbr_GLBL__c = 1 &amp;&amp; RecordType.Name  = &quot;Mastered Address&quot; ||   ( 	Priority_Rank_Nbr_GLBL__c = 1 &amp;&amp;  RecordType.Name = &quot;Mastered Address&quot; &amp;&amp;   		(    			(ISCHANGED(Line_1_Adrs_Txt_GLBL__c )) ||    			(ISCHANGED(Line_2_Adrs_Txt_GLBL__c )) ||   			(ISCHANGED(Line_3_Adrs_Txt_GLBL__c )) ||  			(ISCHANGED(Line_4_Adrs_Txt_GLBL__c )) ||    			(ISCHANGED(City_GLBL__c )) ||                            (ISCHANGED(St_Cd_GLBL__c )) ||  			(ISCHANGED(Adrs_Cntry_Cd_GLBL__c )) ||   			(ISCHANGED(Zip_Postal_Code_GLBL__c )) || 			(ISCHANGED(RecordTypeId))    		)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Primary Address_Contracting_Party</fullName>
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
        <actions>
            <name>Prim_Add_State</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Triggers copying the Address  fields for a Contracting Party to the Primary Address Fields in Accounts of type Contracting Party : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISNEW() &amp;&amp; RecordType.Name  = &quot;Contract Party Address&quot; ||   ( 	RecordType.Name = &quot;Contract Party Address&quot; &amp;&amp;   		(    			(ISCHANGED(Line_1_Adrs_Txt_GLBL__c )) ||    			(ISCHANGED(Line_2_Adrs_Txt_GLBL__c )) ||   			(ISCHANGED(Line_3_Adrs_Txt_GLBL__c )) ||  			(ISCHANGED(Line_4_Adrs_Txt_GLBL__c )) ||    			(ISCHANGED(City_GLBL__c )) ||                           (ISCHANGED(St_Cd_GLBL__c )) ||   			(ISCHANGED(Adrs_Cntry_Cd_GLBL__c )) ||   			(ISCHANGED(Zip_Postal_Code_GLBL__c )) || 			(ISCHANGED(RecordTypeId))    		)  )  &amp;&amp; (Account_GLBL__r.RecordType.Name = &quot;Contracting Party&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Primary Address_Designated_Individual</fullName>
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
        <actions>
            <name>Prim_Add_State</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Triggers copying the Address  fields for an Designated Individual (used for Institutional Notifications) to the Primary Address Fields in Accounts of type Designated Individual : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISNEW() &amp;&amp; RecordType.Name  = &quot;Designated Individual Address&quot; ||   ( 	RecordType.Name = &quot;Designated Individual Address&quot; &amp;&amp;   		(    			(ISCHANGED(Line_1_Adrs_Txt_GLBL__c )) ||    			(ISCHANGED(Line_2_Adrs_Txt_GLBL__c )) ||   			(ISCHANGED(Line_3_Adrs_Txt_GLBL__c )) ||  			(ISCHANGED(Line_4_Adrs_Txt_GLBL__c )) ||    			(ISCHANGED(City_GLBL__c )) ||                          (ISCHANGED(St_Cd_GLBL__c )) ||    			(ISCHANGED(Adrs_Cntry_Cd_GLBL__c )) ||   			(ISCHANGED(Zip_Postal_Code_GLBL__c )) || 			(ISCHANGED(RecordTypeId))    		)  )  &amp;&amp; (Account_GLBL__r.RecordType.Name = &quot;Designated Individual&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Primary Address_Venue</fullName>
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
        <actions>
            <name>Prim_Add_State</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Triggers copying the Address  fields for a Venue or Vendor to the Primary Address Fields in Accounts of type Venue or Vendor with Priority Rank 1 : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISNEW() &amp;&amp; Priority_Rank_Nbr_GLBL__c = 1 &amp;&amp; RecordType.Name  = &quot;Other Address&quot; ||   ( 	Priority_Rank_Nbr_GLBL__c = 1 &amp;&amp;  RecordType.Name = &quot;Other Address&quot; &amp;&amp;   		(    			(ISCHANGED(Line_1_Adrs_Txt_GLBL__c )) ||    			(ISCHANGED(Line_2_Adrs_Txt_GLBL__c )) ||   			(ISCHANGED(Line_3_Adrs_Txt_GLBL__c )) ||  			(ISCHANGED(Line_4_Adrs_Txt_GLBL__c )) ||    			(ISCHANGED(City_GLBL__c )) ||                          (ISCHANGED(St_Cd_GLBL__c )) ||    			(ISCHANGED(Adrs_Cntry_Cd_GLBL__c )) ||   			(ISCHANGED(Zip_Postal_Code_GLBL__c )) || 			(ISCHANGED(RecordTypeId))    		)  )  &amp;&amp; (Account_GLBL__r.RecordType.Name = &quot;Vendor&quot; || Account_GLBL__r.RecordType.Name = &quot;Venue&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Set Account Global ID</fullName>
        <actions>
            <name>Stamp_Global_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Account Global ID on Address when Address is created or Account Lookup is changed : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISNEW() || ISCHANGED( Account_GLBL__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Address Account Name</fullName>
        <actions>
            <name>Update_Address_Account_Name_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Address Account Name to ensure this can be used in Lookup relationship Searches.  Field must remain on Address layout : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
