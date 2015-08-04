/****************************************************************************************************************************************** 
* Class Name   : APOL_ProjectJSON
* Description  : Getting Dynamic JSON for Projects. It also gets the Chatter Updates.                  
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
public with sharing class APOL_ProjectJSON
{
    /*
    * @Method Name                    :  ProjectDetails
    * @Description                    :  Getting Dynamic JSON for Projects .
    * @Return Type                    :  Object
    */
    public static Object ProjectDetails()  {
        //Querying a List of Projects
        List<Apol_Project__c> lstProjects = [Select Name,Project_Lead__r.FullPhotoUrl,The_One_Liner__c, Status__c,Stage__c,
                                             Project_Lead__r.Name, NGD_Pillar__c , Project_Stakeholder_Groups__c ,TransCelerate__c
                                             ,Next_Generation_Development__c, Clinical_Innovation__c,  Project_Lead__r.Email,
                                             Id,(Select Id,Project_Name__c,business_unit__c,Compound1__c, Stage_of_Development__c,
                                                 Therapeutic_Area__c, Trial_Alias1__r.Name,Trial_Phase__c from Applications__r),
                                             problem_statement__c, geography__c, project_description__c,project_Quote__c,
                                             Featured_project__c from APOL_Project__c
                                             where Publish_to_chord__c = true limit 2000];

        //Querying the EntitySubscription objects which contains the projects followed by a user.  
        Set<String> followingProjectsSet = new Set<String>();                                   
        for(EntitySubscription es : [Select ParentId from Entitysubscription where subscriberid = :userinfo.getuserid() and ParentId In :lstProjects limit 1000]){
             followingProjectsSet.add(es.parentId);
         }

        Map<String,List<APOL_ChatterUpdatesJSON.chatterUpdateWrapper>> chatterUpdatesMap
        = APOL_ChatterUpdatesJSON.chatterUpdates(followingProjectsSet);

        JSONGenerator projectJson;            //Creating the Project JSON.
        projectJson = JSON.createGenerator(true);
        projectJson.writeStartArray();

        for(APOL_Project__c projectObj: lstProjects)      {
            projectJson.writeStartObject();
            projectJson.writeStringField(Label.APOL_id,projectObj.id);
            projectJson.writeStringField(Label.APOL_name,projectObj.Name);
            projectJson.writeNumberField(Label.APOL_following,followingProjectsSet.contains(projectObj.Id)==true?1:0);
            projectJson.writefieldname(Label.APOL_updates);
            projectJson.writestartarray();
            if(chatterUpdatesMap.containsKey(projectObj.Id)) {
                for(APOL_ChatterUpdatesJSON.chatterUpdateWrapper cUpdate : chatterUpdatesMap.get(projectObj.Id)) {
                    projectJson.writestartobject();
                    projectJson.writestringfield(Label.APOL_update,ProjectObj.Name+' - '+cUpdate.chatterUpdate);
                    projectJson.writestringfield(Label.APOL_timestamp,cUpdate.timestamp);
                    projectJson.writeendobject();
                }
            }
            projectJson.writeendarray();
            
            projectJson.writeStringField(Label.APOL_shortdesc,APOL_Utility.isNull(projectObj.The_One_Liner__c));
            projectJson.writeStringField(Label.APOL_longDesc,APOL_Utility.isNull(projectObj.Project_Description__c));
            projectJson.writeStringField(Label.APOL_problem,APOL_Utility.isNull(projectObj.Problem_statement__c));
            projectJson.writeStringField(Label.APOL_status,APOL_Utility.isNull(projectObj.Status__c));
            projectJson.writeStringField(Label.APOL_stage,APOL_Utility.isNull(projectObj.Stage__c));
            projectJson.writeNumberField(Label.APOL_featured, projectObj.Featured_Project__c==true?1 : 0);
            projectJson.writeFieldName(Label.APOL_Lead);
            projectJson.writeStartObject();
            projectJson.writeStringField(Label.APOL_name,APOL_Utility.isNull(projectObj.Project_Lead__r.Name));
            projectJson.writeStringField(Label.APOL_picture,APOL_Utility.isNull(projectObj.Project_Lead__r.FullPhotoUrl));
            projectJson.writeStringField(Label.APOL_email,APOL_Utility.isNull(projectObj.Project_Lead__r.email));
            projectJson.writeStringField(Label.APOL_comment, APOL_Utility.isNull(projectObj.Project_Quote__c));
            projectJson.writeEndObject();

            // adding the affecting Changes values
            List<APOL_Applied__c> lstApplied = projectObj.Applications__r;
            if(lstApplied.size() > 0)       {
                projectJson.writeFieldName(Label.APOL_affectingChange);
                projectJson.writeStartArray();
                for(APOL_Applied__c appliedobj : lstApplied)    {
                    projectJson.writeStartObject();
                    projectJson.writeStringField(Label.APOL_trial,APOL_Utility.isNull(appliedobj.Trial_Alias1__r.Name));
                    projectJson.writeStringField(Label.APOL_bu,APOL_Utility.isNull(appliedobj.Business_Unit__c));
                    projectJson.writeStringField(Label.APOL_therapeuticarea,APOL_Utility.isNull(appliedobj.Therapeutic_Area__c));
                    projectJson.writeStringField(Label.APOL_compound,APOL_Utility.isNull(appliedobj.Compound1__c));
                    projectJson.writeStringField(Label.APOL_phase,APOL_Utility.isNull(appliedobj.Trial_Phase__c));
                    projectJson.writeStringField(Label.APOL_status,APOL_Utility.isNull(appliedobj.Stage_of_Development__c));
                    projectJson.writeEndObject();
                }
                projectJson.writeEndArray();
            }

            projectJson.writeStringField(Label.APOL_pillar,APOL_Utility.isNull(projectObj.NGD_Pillar__c));

            // adding the project stakeholder group options
            List<String> lstStakeholderOptions = new List<String>();
            if(projectObj.Project_Stakeholder_Groups__c<>NULL)    {
                lstStakeholderOptions=projectObj.Project_Stakeholder_Groups__c.split(';');
            }

            projectJson.writeFieldName(Label.APOL_stakeholders);
            projectJson.writeStartArray();
            for(String stakeHolderOption : lstStakeholderOptions)       {
                if(stakeHolderOption.toLowerCase() == Label.APOL_patients.substring(0,Label.APOL_patients.length()-1).tolowercase())   {
                    stakeHolderOption = Label.APOL_patients;
                }
                if(stakeHolderOption.toLowerCase() == Label.APOL_investigators.substring(0,Label.APOL_investigators.length()-1).toLowerCase())     {
                    stakeHolderOption = Label.APOL_investigators;
                }
                if(stakeHolderOption != null)  {
                    stakeHolderOption = stakeHolderOption.toLowerCase();
                }
                projectJson.writeString(stakeHolderOption);
            }
            projectJson.writeEndArray();
            List<String> lstGeographyOptions = new List<String>();
            if(projectObj.Geography__c<>NULL)  {
                lstGeographyOptions=projectObj.Geography__c.split(';');
            }
            projectJson.writeFieldName(Label.APOL_geo);
            projectJson.writeStartArray();
            for(String geoOptions : lstGeographyOptions)  {
                projectJson.writeString(geoOptions);
            }
            projectJson.writeEndArray();
            
            // adding the project category values from the 3 checkboxes.
            projectJson.writeFieldName(Label.APOL_Categories);
            projectJson.writeStartArray();
            if(projectObj.TransCelerate__c == TRUE)  {
                projectJson.writeString(APOL_Project__c.TransCelerate__c.getDescribe().getLabel());
            }
            if(projectObj.Next_Generation_Development__c== TRUE)  {
                projectJson.writeString(Label.APOL_NextGenDev);
            }
            if(projectObj.Clinical_Innovation__c== TRUE)        {
                projectJson.writeString(Label.APOL_Clinical_Innovation);
            }
            projectJson.writeEndArray();
            projectJson.writeEndObject();
        }
        projectJson.writeEndArray();
 
        return Json.deserializeUntyped(projectJson.getAsString());
    }
}