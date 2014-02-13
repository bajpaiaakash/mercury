<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Date_Stamp_CAP_Usage_Note_MERC</fullName>
        <description>Date Stamps the CAP Usage note to ensure it&apos;s relevant. Oliver Dunford 9th Nov 2013.</description>
        <field>CAP_Usage_Note_MERC__c</field>
        <formula>TEXT(TODAY()) &amp; &quot;: &quot; &amp;  CAP_Usage_Note_MERC__c &amp;  BR()</formula>
        <name>Date Stamp CAP Usage Note</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Stamp_HCP_Exec_Smmry_MERC</fullName>
        <description>Date stamps important information captured for the HCP. This should be date stamped for each post and passed via integration to Veeva.
Created by John A Adams 12/18/2013</description>
        <field>Exec_Smmry_Note_MERC__c</field>
        <formula>TEXT(TODAY())&amp; &quot;:&quot; &amp;  Exec_Smmry_Note_MERC__c &amp;BR()</formula>
        <name>Date Stamp HCP Executive Summary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>External_ID_Account_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Calculate_Open_Meeting_Fees_MERC</fullName>
        <description>Set Calculate Open Meeting Fees checkbox to FALSE after each record update.</description>
        <field>Calculate_Open_Meeting_Fees_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Set Calculate Open Meeting Fees</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_HCP_CV_Verif_to_Not_Required_MERC</fullName>
        <description>Sets HCP CV Verification Required to Not Required should the HCP no longer be a Tier 1. Oliver Dunford 15th Jan 2014.</description>
        <field>Tier_1_HCP_CV_Checked_MERC__c</field>
        <literalValue>Not Required</literalValue>
        <name>Set HCP CV Verification to Not Required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Service_Provider_Tier_1_MERC</fullName>
        <description>Sets Service Provider to Tier 1.  Once CV has been verified.  Oliver Dunford Jan 15th 2014.</description>
        <field>Service_Provider_Tier_MERC__c</field>
        <formula>1</formula>
        <name>Set Service Provider Tier 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Initiate_Tiering_MERC</fullName>
        <description>Unchecks Initiate Tiering post execution.  Oliver Dunford 15th Jan 2014.</description>
        <field>Initiate_Tiering_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Initiate Tiering</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Initiate_Tiering_Tier_1_MERC</fullName>
        <description>Unchecks the Initiate Tiering post execution of workflow.  Oliver Dunford 15th Jan 2014.</description>
        <field>Initiate_Tiering_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Initiate Tiering Tier 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CV_Tier_1_Check_MERC</fullName>
        <field>Tier_1_HCP_CV_Checked_MERC__c</field>
        <literalValue>Confirmed HCP is Tier 1</literalValue>
        <name>Update CV Tier 1 Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CV_Tier_1_Needs_Review_MERC</fullName>
        <description>Update to Required if HCP returns Tier 1.  Oliver Dunford 15th Jan 2014.</description>
        <field>Tier_1_HCP_CV_Checked_MERC__c</field>
        <literalValue>Needs Review</literalValue>
        <name>Update CV Tier 1 to Needs Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Calculate_Open_Fees_MERC</fullName>
        <description>Updates the Calculate Open Meeting Fees checkbox to ensure it&apos;s only set once. Oliver Dunford 9th Nov 2013.</description>
        <field>Calculate_Open_Meeting_Fees_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Update Calculate Open Fees</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Service_Provider_Tier_MERC</fullName>
        <description>Updates the Service Provider Tier for Tier 2 and 3 HCP&apos;s.  Cannot auto-update Tier 1&apos;s. Oliver Dunford 14th Jan 2014.</description>
        <field>Service_Provider_Tier_MERC__c</field>
        <formula>IF(AND( 
 Tier_3_Criteria_Met_MERC__c = &quot;Yes&quot;, 
 Tier_2_Criteria_Met_MERC__c = &quot;Yes&quot;,
 Tier_1_Criteria_Met_MERC__c = &quot;No&quot;  
),2,
IF(AND( 
 Tier_3_Criteria_Met_MERC__c = &quot;Yes&quot;, 
 Tier_2_Criteria_Met_MERC__c = &quot;No&quot;,
 Tier_1_Criteria_Met_MERC__c = &quot;No&quot;  
),3, null))</formula>
        <name>Update Service Provider Tier</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Tier_1_Criteria_Met_MERC</fullName>
        <description>Update the Tier 1 Criteria met if all Tier 3 criteria are met and 5 out of 8 Tier 1 criteria are met.  Oliver Dunford 14th Jan 2014.</description>
        <field>Tier_1_Criteria_Met_MERC__c</field>
        <formula>IF(
   AND( 
     Tier_1_Score_MERC__c &gt;= 5, 
     Tier_3_Criteria_Met_MERC__c = &quot;Yes&quot; 
   ),&quot;Yes&quot;, &quot;No&quot;
)</formula>
        <name>Update Tier 1 Criteria Met</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Tier_1_Score_MERC</fullName>
        <description>Updates Tier 1 score based on FMV rules. Oliver Dunford 14th Jan 2014.</description>
        <field>Tier_1_Score_MERC__c</field>
        <formula>IF(TEXT(Practicing_for_MERC__c) &lt;&gt; &quot;&lt;5 Years&quot;, 1, 0) + 
IF((TEXT(Regional_Leadership_Role_MERC__c ) = &quot;Yes&quot;) || (TEXT(National_Inter_Leadership_Role_MERC__c ) = &quot;Yes&quot;), 1, 0) + 
IF(TEXT(Journal_Articles_MERC__c) = &quot;5+&quot;, 1,0) + 
IF(TEXT(Reviewer_or_Editor_MERC__c) = &quot;Yes&quot;, 1, 0) + 
IF(TEXT(Instructor_Assistant_Clinical_Prof_MERC__c ) = &quot;Yes&quot;, 1,0) + 
IF(TEXT(Associate_or_Full_Professor_MERC__c) = &quot;Yes&quot;, 1, 0) +
IF(TEXT( Clinical_Trial_PI_MERC__c ) = &quot;Yes - 2 or more&quot;, 1, 0) + IF(TEXT(Advisory_Board_Experience_MERC__c) = &quot;Yes&quot;, 1, 0) + IF(TEXT(Multiple_Specialties_MERC__c) = &quot;Yes&quot;, 1, 0)</formula>
        <name>Update Tier 1 Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Tier_2_Criteria_Met_MERC</fullName>
        <description>Updates the Criteria Met field if the Tier score is &gt;= 5. Oliver Dunford 14th Jan 2014.</description>
        <field>Tier_2_Criteria_Met_MERC__c</field>
        <formula>IF(AND(
  Tier_2_Score_MERC__c &gt;= 5,
  Tier_3_Criteria_Met_MERC__c = &quot;Yes&quot;
),&quot;Yes&quot;, &quot;No&quot;)</formula>
        <name>Update Tier 2 Criteria Met</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Tier_2_Score_MERC</fullName>
        <description>Updates Tier 2 Score based on FMV rule Criteria. Oliver Dunford 13th Jan 2014.</description>
        <field>Tier_2_Score_MERC__c</field>
        <formula>IF(TEXT(Practicing_for_MERC__c) &lt;&gt; &quot;&lt;5 Years&quot;, 1, 0) +
IF((TEXT(Regional_Leadership_Role_MERC__c ) = &quot;Yes&quot;) ||  (TEXT(National_Inter_Leadership_Role_MERC__c ) = &quot;Yes&quot;), 1, 0) + IF( TEXT(Journal_Articles_MERC__c) &lt;&gt; &quot;0-2&quot;, 1,0) + IF( TEXT(Reviewer_or_Editor_MERC__c) = &quot;Yes&quot;, 1, 0) + IF((TEXT( Instructor_Assistant_Clinical_Prof_MERC__c ) = &quot;Yes&quot;) ||  (TEXT( Associate_or_Full_Professor_MERC__c ) = &quot;Yes&quot;), 1, 0) + IF((TEXT( Participated_in_Clinical_Trials_MERC__c ) = &quot;Yes&quot;) ||  (TEXT( Clinical_Trial_PI_MERC__c ) &lt;&gt; &quot;No&quot;), 1, 0) + IF(TEXT(Advisory_Board_Experience_MERC__c) = &quot;Yes&quot;, 1, 0) +  IF(TEXT(Multiple_Specialties_MERC__c) = &quot;Yes&quot;, 1, 0)</formula>
        <name>Update Tier 2 Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Tier_3_Criteria_Met_MERC</fullName>
        <description>Update Tier 3 Criteria met based on Results.  Oliver Dunford 13th Jan 2014.</description>
        <field>Tier_3_Criteria_Met_MERC__c</field>
        <formula>IF( AND (
 TEXT(Licensed_HCP_MERC__c) = &quot;Yes&quot;,
 TEXT(Experience_MERC__c) = &quot;Yes&quot;,
 TEXT(Influential_MERC__c) = &quot;Yes&quot;),
 &quot;Yes&quot;, &quot;No&quot;
)</formula>
        <name>Update Tier 3 Criteria Met</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Tier_3_Score_MERC</fullName>
        <description>Updates Tier 3 Score based on results from rule criteria. Oliver Dunford 13th Jan 2014.</description>
        <field>Tier_3_Score_MERC__c</field>
        <formula>IF(TEXT(Licensed_HCP_MERC__c) = &quot;Yes&quot;, 1,0) +
IF(TEXT(Experience_MERC__c) = &quot;Yes&quot;, 1,0) +
IF(TEXT(Influential_MERC__c) = &quot;Yes&quot;, 1,0)</formula>
        <name>Update Tier 3 Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>RTI_Account_Updated</fullName>
        <apiVersion>29.0</apiVersion>
        <endpointUrl>http://ec2-54-227-9-128.compute-1.amazonaws.com/rti-development/v1/genericUpdated</endpointUrl>
        <fields>Academic_Qualifications_MERC__c</fields>
        <fields>AccountNumber</fields>
        <fields>AccountSource</fields>
        <fields>Account_Add_Reason_MERC__c</fields>
        <fields>Advisory_Board_Experience_MERC__c</fields>
        <fields>Allocated_CAP_MERC__c</fields>
        <fields>Altrnt_Nm_GLBL__c</fields>
        <fields>AnnualRevenue</fields>
        <fields>Annual_CAP_Limit_MERC__c</fields>
        <fields>Approval_MERC__c</fields>
        <fields>Associate_or_Full_Professor_MERC__c</fields>
        <fields>BillingCity</fields>
        <fields>BillingCountry</fields>
        <fields>BillingLatitude</fields>
        <fields>BillingLongitude</fields>
        <fields>BillingPostalCode</fields>
        <fields>BillingState</fields>
        <fields>BillingStreet</fields>
        <fields>Bnft_Dsgn_Cd_GLBL__c</fields>
        <fields>Bsns_Nm2_GLBL__c</fields>
        <fields>Bsns_Nm3_GLBL__c</fields>
        <fields>CAP_Usage_Note_MERC__c</fields>
        <fields>CODS_End_Date_GLBL__c</fields>
        <fields>CODS_Merge_MERC__c</fields>
        <fields>Calculate_Open_Meeting_Fees_MERC__c</fields>
        <fields>Cellular_Phone_Cntry_Cd_GLBL__c</fields>
        <fields>Clinical_Trial_PI_MERC__c</fields>
        <fields>Clsfctn_Cd_GLBL__c</fields>
        <fields>Clsfctn_Desc_GLBL__c</fields>
        <fields>Cntrct_Elgblty_Sts_Txt_GLBL__c</fields>
        <fields>Cntrct_Nm_GLBL__c</fields>
        <fields>Cntrct_Shrt_Nm_GLBL__c</fields>
        <fields>Cntry_Cd_GLBL__c</fields>
        <fields>Communication_Preference_MERC__c</fields>
        <fields>Consulting_Project_Paid_CAP_MERC__c</fields>
        <fields>Contract_Limitations_on_Use_MERC__c</fields>
        <fields>Cost_Cntr_Nbr_GLBL__c</fields>
        <fields>Cost_Cntr_Nm_GLBL__c</fields>
        <fields>Country_Code_MERC__c</fields>
        <fields>Country_of_Residence_GLBL__c</fields>
        <fields>Crdntl_Cd2_GLBL__c</fields>
        <fields>Crdntl_Cd3_GLBL__c</fields>
        <fields>Crdntl_Lvl2_GLBL__c</fields>
        <fields>Crdntl_Lvl3_GLBL__c</fields>
        <fields>Crdntl_Lvl_GLBL__c</fields>
        <fields>Crdntl_Typ_Cd2_GLBL__c</fields>
        <fields>Crdntl_Typ_Cd3_GLBL__c</fields>
        <fields>Crdntl_Typ_Cd_GLBL__c</fields>
        <fields>CreatedById</fields>
        <fields>CreatedDate</fields>
        <fields>Credential_Code_GLBL__c</fields>
        <fields>CurrencyIsoCode</fields>
        <fields>Cust_Grp_Cd_GLBL__c</fields>
        <fields>Cust_Id_GLBL__c</fields>
        <fields>Cust_Typ_Cd_GLBL__c</fields>
        <fields>Cust_Typ_Desc_GLBL__c</fields>
        <fields>Decd_Flg_GLBL__c</fields>
        <fields>Del_Date_GLBL__c</fields>
        <fields>Del_Flg_GLBL__c</fields>
        <fields>Dept_Flg_GLBL__c</fields>
        <fields>Description</fields>
        <fields>Dspnsng_Acct_Flg_GLBL__c</fields>
        <fields>Efctv_End_Dt_GLBL__c</fields>
        <fields>Efctv_Start_Dt_GLBL__c</fields>
        <fields>Elctrnc_Adrs2_Cntry_Prfx_Cd_GLBL__c</fields>
        <fields>Elctrnc_Adrs2_Extnsn_Cd_GLBL__c</fields>
        <fields>Elctrnc_Adrs2_Txt_GLBL__c</fields>
        <fields>Elctrnc_Adrs_Cntry_Prfx_Cd_GLBL__c</fields>
        <fields>Elctrnc_Adrs_Elc_Txt_GLBL__c</fields>
        <fields>Elctrnc_Adrs_Extnsn_Cd_GLBL__c</fields>
        <fields>Elctrnc_Adrs_Fax_Cntry_Prfx_Cd_GLBL__c</fields>
        <fields>Elctrnc_Adrs_Fax_Extnsn_Cd_GLBL__c</fields>
        <fields>Elctrnc_Adrs_Fax_Txt_GLBL__c</fields>
        <fields>Elctrnc_Adrs_Txt_GLBL__c</fields>
        <fields>Elctrnc_Adrs_Web_Txt_GLBL__c</fields>
        <fields>Employed_by_Government_Institution_GLBL__c</fields>
        <fields>Exec_Smmry_Note_MERC__c</fields>
        <fields>Experience_MERC__c</fields>
        <fields>FMV_Criteria_Map_MERC__c</fields>
        <fields>Fax</fields>
        <fields>Fax_Phone_Cntry_Cd_GLBL__c</fields>
        <fields>FirstName</fields>
        <fields>Formulary_Id_GLBL__c</fields>
        <fields>Frmr_Nm_GLBL__c</fields>
        <fields>Full_Nm_GLBL__c</fields>
        <fields>Gndr_Cd_GLBL__c</fields>
        <fields>Gndr_Desc_GLBL__c</fields>
        <fields>Governance_Level_GLBL__c</fields>
        <fields>Govt_Flg_GLBL__c</fields>
        <fields>HCP_Care_Information_MERC__c</fields>
        <fields>Has_MSA_MERC__c</fields>
        <fields>Hospital_Leadership_Role_MERC__c</fields>
        <fields>Id</fields>
        <fields>Ims_Prscrbr_Flg_GLBL__c</fields>
        <fields>Ims_Xponent_Flg_GLBL__c</fields>
        <fields>Indstry_Grp_Cd_GLBL__c</fields>
        <fields>Industry</fields>
        <fields>Influential_MERC__c</fields>
        <fields>Initials_GLBL__c</fields>
        <fields>Initiate_Tiering_MERC__c</fields>
        <fields>Institution_Administrator_GLBL__c</fields>
        <fields>Instructor_Assistant_Clinical_Prof_MERC__c</fields>
        <fields>IsDeleted</fields>
        <fields>IsPersonAccount</fields>
        <fields>Jigsaw</fields>
        <fields>JigsawCompanyId</fields>
        <fields>Journal_Articles_MERC__c</fields>
        <fields>Justification_for_Preferred_Venue_MERC__c</fields>
        <fields>Key_Opinion_Leader_GLBL__c</fields>
        <fields>Language_Preference_MERC__c</fields>
        <fields>LastActivityDate</fields>
        <fields>LastModifiedById</fields>
        <fields>LastModifiedDate</fields>
        <fields>LastName</fields>
        <fields>Last_Review_Date_MERC__c</fields>
        <fields>Licensed_HCP_MERC__c</fields>
        <fields>Lilly_Company_Code_GLBL__c</fields>
        <fields>Lilly_Company_VAT_ID_GLBL__c</fields>
        <fields>MSA_Expiration_Date_MERC__c</fields>
        <fields>MasterRecordId</fields>
        <fields>Mdl_Nm_GLBL__c</fields>
        <fields>Mercury_External_Id_MERC__c</fields>
        <fields>Merge_DT_GLBL__c</fields>
        <fields>Mltry_Flg_GLBL__c</fields>
        <fields>Multiple_Specialties_MERC__c</fields>
        <fields>Name</fields>
        <fields>Name_of_Institution_GLBL__c</fields>
        <fields>National_Inter_Leadership_Role_MERC__c</fields>
        <fields>NumberOfEmployees</fields>
        <fields>ODS_Ld_Tmstmp_GLBL__c</fields>
        <fields>ODS_Ld_Usr_GLBL__c</fields>
        <fields>ODS_Lst_Updt_Tmstmp_GLBL__c</fields>
        <fields>ODS_Lst_Updt_Usr_GLBL__c</fields>
        <fields>Org_Unit_Cd_GLBL__c</fields>
        <fields>Org_Unit_Desc_GLBL__c</fields>
        <fields>Orig_Party_Rec_Type_CD_GLBL__c</fields>
        <fields>Original_Party_ID_GLBL__c</fields>
        <fields>Other_Specialities_GLBL__c</fields>
        <fields>Other_Specialty_Codes_GLBL__c</fields>
        <fields>Othr_Ttl_Txt_GLBL__c</fields>
        <fields>OwnerId</fields>
        <fields>Ownership</fields>
        <fields>Paid_CAP_MERC__c</fields>
        <fields>ParentId</fields>
        <fields>Participated_in_Clinical_Trials_MERC__c</fields>
        <fields>Party_Rcrd_Typ_Cd_GLBL__c</fields>
        <fields>Party_Sts_Cd_GLBL__c</fields>
        <fields>Party_Sts_Desc_GLBL__c</fields>
        <fields>Payment_Required_MERC__c</fields>
        <fields>PersonAssistantName</fields>
        <fields>PersonAssistantPhone</fields>
        <fields>PersonBirthdate</fields>
        <fields>PersonContactId</fields>
        <fields>PersonDepartment</fields>
        <fields>PersonDoNotCall</fields>
        <fields>PersonEmail</fields>
        <fields>PersonEmailBouncedDate</fields>
        <fields>PersonEmailBouncedReason</fields>
        <fields>PersonHasOptedOutOfEmail</fields>
        <fields>PersonHasOptedOutOfFax</fields>
        <fields>PersonHomePhone</fields>
        <fields>PersonLastCURequestDate</fields>
        <fields>PersonLastCUUpdateDate</fields>
        <fields>PersonLeadSource</fields>
        <fields>PersonMailingCity</fields>
        <fields>PersonMailingCountry</fields>
        <fields>PersonMailingLatitude</fields>
        <fields>PersonMailingLongitude</fields>
        <fields>PersonMailingPostalCode</fields>
        <fields>PersonMailingState</fields>
        <fields>PersonMailingStreet</fields>
        <fields>PersonMobilePhone</fields>
        <fields>PersonOtherCity</fields>
        <fields>PersonOtherCountry</fields>
        <fields>PersonOtherLatitude</fields>
        <fields>PersonOtherLongitude</fields>
        <fields>PersonOtherPhone</fields>
        <fields>PersonOtherPostalCode</fields>
        <fields>PersonOtherState</fields>
        <fields>PersonOtherStreet</fields>
        <fields>PersonTitle</fields>
        <fields>Phone</fields>
        <fields>Plan_Typ_Cd_GLBL__c</fields>
        <fields>Pmt_Nm_GLBL__c</fields>
        <fields>Position_Cd_GLBL__c</fields>
        <fields>Position_Desc_GLBL__c</fields>
        <fields>Practicing_for_MERC__c</fields>
        <fields>Preferred_Venue_MERC__c</fields>
        <fields>Prfrd_Lang_Cd_GLBL__c</fields>
        <fields>Prfrd_Nm_GLBL__c</fields>
        <fields>Prfsnl_Start_Dt_GLBL__c</fields>
        <fields>Prim_Affil_Addr_City_GLBL__c</fields>
        <fields>Prim_Affil_Addr_Country_GLBL__c</fields>
        <fields>Prim_Affil_Addr_Line1_GLBL__c</fields>
        <fields>Prim_Affil_Addr_Line2_GLBL__c</fields>
        <fields>Prim_Affil_HCO_GLBL__c</fields>
        <fields>Prim_Affil_Pstl_Cd_Extnsn_GLBL__c</fields>
        <fields>Primary_Addr_City_GLBL__c</fields>
        <fields>Primary_Addr_Line1_GLBL__c</fields>
        <fields>Primary_Addr_Line2_GLBL__c</fields>
        <fields>Primary_Address_Country_GLBL__c</fields>
        <fields>Primary_HCO_GLBL__c</fields>
        <fields>Primary_Pstl_Cd_Extnsn_GLBL__c</fields>
        <fields>Prof_Title_Txt_GLBL__c</fields>
        <fields>Property_Remarks_MERC__c</fields>
        <fields>Prsnl_Nbr_GLBL__c</fields>
        <fields>Quality_Level_GLBL__c</fields>
        <fields>Rating</fields>
        <fields>RecordTypeId</fields>
        <fields>Regional_Leadership_Role_MERC__c</fields>
        <fields>Relationship_Owner_MERC__c</fields>
        <fields>Remaining_CAP_MERC__c</fields>
        <fields>Reserved_CAP_MERC__c</fields>
        <fields>Reviewer_or_Editor_MERC__c</fields>
        <fields>Sales_Force_Code_GLBL__c</fields>
        <fields>Sales_Force_Description_GLBL__c</fields>
        <fields>Salutation</fields>
        <fields>Salutation_Txt_GLBL__c</fields>
        <fields>Scnd_Nm_GLBL__c</fields>
        <fields>Scnd_Ttl_Txt_GLBL__c</fields>
        <fields>Service_Provider_MERC__c</fields>
        <fields>Service_Provider_Tier_MERC__c</fields>
        <fields>Sfx_Nm_GLBL__c</fields>
        <fields>ShippingCity</fields>
        <fields>ShippingCountry</fields>
        <fields>ShippingLatitude</fields>
        <fields>ShippingLongitude</fields>
        <fields>ShippingPostalCode</fields>
        <fields>ShippingState</fields>
        <fields>ShippingStreet</fields>
        <fields>Sic</fields>
        <fields>SicDesc</fields>
        <fields>Site</fields>
        <fields>Social_Security_Number_MERC__c</fields>
        <fields>Source_Block_GLBL__c</fields>
        <fields>Spclty_Cd_GLBL__c</fields>
        <fields>Spclty_Desc_GLBL__c</fields>
        <fields>Speaking_Paid_CAP_MERC__c</fields>
        <fields>Src_Block_Flg_GLBL__c</fields>
        <fields>Src_Sys_Cd_GLBL__c</fields>
        <fields>Status_Cd_GLBL__c</fields>
        <fields>Status_Desc_GLBL__c</fields>
        <fields>Status_MERC__c</fields>
        <fields>Store_Loc_Nbr_GLBL__c</fields>
        <fields>Sub_Clsfctn_Cd_GLBL__c</fields>
        <fields>Sub_Clsfctn_Desc_GLBL__c</fields>
        <fields>Supervisor_Prsnl_Nbr_GLBL__c</fields>
        <fields>SystemModstamp</fields>
        <fields>System_Id_GLBL__c</fields>
        <fields>Territory_Id_GLBL__c</fields>
        <fields>TickerSymbol</fields>
        <fields>Tier_1_Criteria_Met_MERC__c</fields>
        <fields>Tier_1_HCP_CV_Checked_MERC__c</fields>
        <fields>Tier_1_Score_MERC__c</fields>
        <fields>Tier_2_Criteria_Met_MERC__c</fields>
        <fields>Tier_2_Score_MERC__c</fields>
        <fields>Tier_3_Criteria_Met_MERC__c</fields>
        <fields>Tier_3_Score_MERC__c</fields>
        <fields>Title_Desc_GLBL__c</fields>
        <fields>Transparency_Reporting_Opt_Out_MERC__c</fields>
        <fields>Trng_Acct_Flg_GLBL__c</fields>
        <fields>Trtry_Cd_GLBL__c</fields>
        <fields>Trtry_Desc_GLBL__c</fields>
        <fields>Type</fields>
        <fields>Utilised_CAP_MERC__c</fields>
        <fields>Veeva_Organization_MERC__c</fields>
        <fields>Venue_Preference_Type_MERC__c</fields>
        <fields>Voicemail_Phone_Cd_GLBL__c</fields>
        <fields>Voicemail_Phone_Nbr_GLBL__c</fields>
        <fields>Website</fields>
        <fields>Whlslr_Cd_GLBL__c</fields>
        <fields>Work_Cntry_Cd_GLBL__c</fields>
        <fields>Work_Country_Desc_GLBL__c</fields>
        <fields>Work_Phone_Cntry_Cd_GLBL__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>helmerdavid@gso1.lly</integrationUser>
        <name>RTI - Account Updated</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Clear Calculate Open Meeting Fees_MERC</fullName>
        <actions>
            <name>Set_Calculate_Open_Meeting_Fees_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the Calculate Open Meeting Fees checkbox after each record update</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Date Stamp CAP Usage Note_MERC</fullName>
        <actions>
            <name>Date_Stamp_CAP_Usage_Note_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to date stamp CAP usage note so that it you can judge if it&apos;s relevant or not.</description>
        <formula>AND (NOT ISBLANK( CAP_Usage_Note_MERC__c ),  ISCHANGED(CAP_Usage_Note_MERC__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Date Stamp HCP Executive Summary_MERC</fullName>
        <actions>
            <name>Date_Stamp_HCP_Exec_Smmry_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to date stamp important information captured for the HCP. This should be date stamped for each post and passed via integration to Veeva.</description>
        <formula>AND (NOT ISBLANK( Exec_Smmry_Note_MERC__c ), ISCHANGED( Exec_Smmry_Note_MERC__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Mercury External ID-Account_MERC</fullName>
        <actions>
            <name>External_ID_Account_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RTI - Account Updated</fullName>
        <actions>
            <name>RTI_Account_Updated</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISCHANGED( RTI_Transaction_ID_MERC__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Tier Initiation Update</fullName>
        <actions>
            <name>Uncheck_Initiate_Tiering_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Service_Provider_Tier_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Tier_1_Criteria_Met_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Tier_1_Score_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Tier_2_Criteria_Met_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Tier_2_Score_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Tier_3_Criteria_Met_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Tier_3_Score_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Initiate_Tiering_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates Tier Criteria based on Scoring. Oliver Dunford Jan 13th 2014.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update CV checked for Tier 2 %26 3_MERC</fullName>
        <actions>
            <name>Set_HCP_CV_Verif_to_Not_Required_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the CV checked field back to Not Required should the Tier change from 1 to 2 or 3. Oliver Dunford 15th Jan 2014.</description>
        <formula>Tier_1_Criteria_Met_MERC__c = &apos;No&apos; &amp;&amp;  (           ISPICKVAL(Tier_1_HCP_CV_Checked_MERC__c, &quot;Confirmed HCP is Tier 1&quot;) ||           ISPICKVAL(Tier_1_HCP_CV_Checked_MERC__c, &quot;HCP is NOT Tier 1&quot;) ||           ISPICKVAL(Tier_1_HCP_CV_Checked_MERC__c, &quot;Needs Review&quot;) ||           ISPICKVAL(Tier_1_HCP_CV_Checked_MERC__c, &quot;&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Calculate Open Fees_MERC</fullName>
        <actions>
            <name>Update_Calculate_Open_Fees_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Calculate_Open_Meeting_Fees_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Resets the Calculate Open Fees checkbox once it&apos;s been set.  It should only be triggered once.  Oliver Dunford 9th Nov 2013.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Service Provider Tier for Tier 1_MERC</fullName>
        <actions>
            <name>Set_Service_Provider_Tier_1_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Once a HCP&apos;s CV has been verified, set the Service Provider Tier to 1. Oliver Dunford 15th Jan 2014.</description>
        <formula>AND(ISCHANGED(Tier_1_HCP_CV_Checked_MERC__c), ISPICKVAL( Tier_1_HCP_CV_Checked_MERC__c , &quot;Confirmed HCP is Tier 1&quot;),  Tier_1_Criteria_Met_MERC__c = &quot;Yes&quot;,  Tier_2_Criteria_Met_MERC__c = &quot;Yes&quot;,  Tier_3_Criteria_Met_MERC__c = &quot;Yes&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Tier 1 HCP CV Checked_MERC</fullName>
        <actions>
            <name>Update_CV_Tier_1_Needs_Review_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Ensures the CV is checked before setting the Service Provider Tier to 1. Oliver Dunford 15th Jan 2014.</description>
        <formula>Tier_1_Criteria_Met_MERC__c = &quot;Yes&quot; &amp;&amp;  (  ISPICKVAL(Tier_1_HCP_CV_Checked_MERC__c, &quot;&quot;) ||  ISPICKVAL(Tier_1_HCP_CV_Checked_MERC__c, &quot;HCP is NOT Tier 1&quot;) ||  ISPICKVAL(Tier_1_HCP_CV_Checked_MERC__c, &quot;Not Required&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
