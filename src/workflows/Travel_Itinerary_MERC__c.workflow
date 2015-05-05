<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Set_Hotel_CheckOut_Time</fullName>
        <description>Sets the checkin time of the Hotel should it exist on the Account record : MERC : Created on 28/04/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Sgmnt_End_TS_MERC__c</field>
        <formula>DATETIMEVALUE(TEXT(YEAR(DATEVALUE(Sgmnt_End_TS_MERC__c))) +&quot;-&quot;+ TEXT(MONTH(DATEVALUE(Sgmnt_End_TS_MERC__c))) +&quot;-&quot;+ TEXT(DAY(DATEVALUE(Sgmnt_End_TS_MERC__c))) + &quot; &quot; + ( Meeting_Vendor_MERC__r.Account_MERC__r.Hotel_Check_out_Time_MERC__c ) + &quot;:00Z&quot;)</formula>
        <name>MERC_Set_Hotel_CheckOut_Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Set_Hotel_Checkin_Time</fullName>
        <description>Sets the checkin time of the Hotel should it exist on the Account record : MERC : Created on 28/04/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Sgmnt_Bgin_TS_MERC__c</field>
        <formula>DATETIMEVALUE(TEXT(YEAR(DATEVALUE(Sgmnt_Bgin_TS_MERC__c))) +&quot;-&quot;+ TEXT(MONTH(DATEVALUE(Sgmnt_Bgin_TS_MERC__c))) +&quot;-&quot;+ TEXT(DAY(DATEVALUE(Sgmnt_Bgin_TS_MERC__c))) + &quot; &quot; + ( Meeting_Vendor_MERC__r.Account_MERC__r.Hotel_Check_in_Time_MERC__c  ) + &quot;:00Z&quot;)</formula>
        <name>MERC_Set Hotel Checkin Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Update Check In%2FOut Times</fullName>
        <actions>
            <name>MERC_Set_Hotel_CheckOut_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MERC_Set_Hotel_Checkin_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Pulls down the check in/out times from the hotel vendor and updates the travel itinerary upon record save : MERC : Created on 21/04/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>(
(ISNEW() &amp;&amp; 
Meeting_Vendor_MERC__r.Account_MERC__r.Hotel_Check_in_Time_MERC__c &lt;&gt; &quot;&quot; &amp;&amp; 
Meeting_Vendor_MERC__r.Account_MERC__r.Hotel_Check_out_Time_MERC__c &lt;&gt; &quot;&quot;) 

|| 

(ISCHANGED( Meeting_Vendor_MERC__c) &amp;&amp; Meeting_Vendor_MERC__r.Account_MERC__r.Hotel_Check_in_Time_MERC__c &lt;&gt; &quot;&quot; &amp;&amp; Meeting_Vendor_MERC__r.Account_MERC__r.Hotel_Check_out_Time_MERC__c &lt;&gt; &quot;&quot;) 

|| 

(ISCHANGED( Sgmnt_Bgin_TS_MERC__c ) &amp;&amp; 
Meeting_Vendor_MERC__r.Account_MERC__r.Hotel_Check_in_Time_MERC__c &lt;&gt; &quot;&quot; &amp;&amp;
Meeting_Vendor_MERC__r.Account_MERC__r.Hotel_Check_out_Time_MERC__c &lt;&gt; &quot;&quot;)

|| 

(ISCHANGED( Sgmnt_End_TS_MERC__c ) &amp;&amp; 
Meeting_Vendor_MERC__r.Account_MERC__r.Hotel_Check_in_Time_MERC__c &lt;&gt; &quot;&quot; &amp;&amp;
Meeting_Vendor_MERC__r.Account_MERC__r.Hotel_Check_out_Time_MERC__c &lt;&gt; &quot;&quot;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
