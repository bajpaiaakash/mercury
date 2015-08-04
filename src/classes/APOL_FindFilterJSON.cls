/****************************************************************************************************************************************** 
* Class Name   : APOL_FindFilterJSON
* Description  : Getting Dynamic JSON for Find Filter on the Chord Home Page. 
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
public with sharing class APOL_FindFilterJSON
{
    /* 
    * @Method Name                    :  FindFilters
    * @Description                    :  Getting Dynamic JSON for Find Filter . 
    * @Return Type                    :  Object
    
    */  
    public static Object FindFilters()   {
        //JSON for Find Filter
        JSONGenerator findFilterJson = JSON.createGenerator(true);
        findFilterJson.writestartarray();
        findFilterJson.writestartobject();
        findFilterJson.writestringfield(Label.APOL_title,Label.APOL_category);
        findFilterJson.writeFieldName(Label.APOL_Categories);
        findFilterJson.writeStartArray();
        findFilterJson.writestartobject();
        // adding the category filter values
        findFilterJson.Writestringfield(Label.APOL_categoryName,APOL_Project__c.Clinical_Innovation__c.getDescribe().getLabel());
        findFilterJson.Writestringfield(Label.APOL_categoryName,APOL_Project__c.Next_Generation_Development__c.getDescribe().getLabel());
        findFilterJson.Writestringfield(Label.APOL_categoryName,APOL_Project__c.TransCelerate__c.getDescribe().getLabel());
        findFilterJson.writeendobject();
        findFilterJson.writeEndArray();
        findFilterJson.writeendobject();
        findFilterJson.writestartobject();
        findFilterJson.writestringfield(Label.APOL_title,Label.APOL_stage);
        findFilterJson.writeFieldName(Label.APOL_categories);
        findFilterJson.writeStartArray();
        findFilterJson.writestartobject();
        // adding the stage filter values
        for( Schema.PicklistEntry stageOptions : APOL_Project__c.Stage__c.getDescribe().getPicklistValues())       {
            if(!stageOptions.getlabel().contains(Label.APOL_Production))     {
                findFilterJson.Writestringfield(Label.APOL_categoryname,stageOptions.getlabel());
            }
        }
        findFilterJson.Writestringfield(Label.APOL_categoryname,Label.APOL_Production);
        findFilterJson.writeendobject();
        findFilterJson.writeEndArray();
        findFilterJson.writeendobject();
        findFilterJson.writestartobject();
        findFilterJson.writestringfield(Label.APOL_title,Label.APOL_Business_Unit);
        findFilterJson.writeFieldName(Label.APOL_categories);
        findFilterJson.writeStartArray();
        findFilterJson.writestartobject();
        // adding the Business unit filter values
        for( Schema.PicklistEntry buOptions : APOL_Applied__c.Business_Unit__c.getDescribe().getPicklistValues())      {
            findFilterJson.Writestringfield(Label.APOL_categoryName,buOptions.getlabel());
        }
        findFilterJson.writeendobject();
        findFilterJson.writeEndArray();
        findFilterJson.writeendobject();
        findFilterJson.writestartobject();
        findFilterJson.writestringfield(Label.APOL_title,Label.APOL_geo);
        findFilterJson.writeFieldName(Label.APOL_categories);
        findFilterJson.writeStartArray();
        findFilterJson.writestartobject();
        // adding the geography filter values
        for( Schema.PicklistEntry geoOptions : APOL_Project__c.Geography__c.getDescribe().getPicklistValues())       {
            findFilterJson.Writestringfield(Label.APOL_categoryName,geoOptions.getlabel());
        }
        findFilterJson.writeendobject();
        findFilterJson.writeEndArray();
        findFilterJson.writeendobject();
        findFilterJson.writestartobject();
        
        findFilterJson.writeendobject();
        findFilterJson.writeendarray();
        return Json.deserializeUntyped(findFilterJson.getAsString());
    }
}