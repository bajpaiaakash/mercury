/*
*  Classname : Iriss_Submission_Region_Trigger_Helper
*   Created By: Deloitte USI    
*   Created Date: 25-Mar-2014
*   Description: This class is used by trigger Iriss_Submission_Region_BD_BU to update the Region text field on the respective Submissions
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/
public with sharing class IRIS_Submission_Region_Trigger_Helper{
    private List<IRIS_Submission_Region__c> lstUpdatedSubRegions{set;get;} 
    private set<Id> setSubIds{set;get;}
    private map<id,IRIS_Submission__c> mapSubId_SubRec{set;get;}
    public static boolean hasTakenCareOf{set;get;}
    
    public void updateRegionTextField(List<IRIS_Submission_Region__c> lstSubRegions , map<id,IRIS_Submission_Region__c> oldMapSubRegion){
        // get only the submission countries which have the Region updated
        getUpdatedSubRegions(lstSubRegions , oldMapSubRegion);
        if(lstUpdatedSubRegions != null && lstUpdatedSubRegions.size()>0){
            mapSubId_SubRec = new Map<id,IRIS_Submission__c>([Select Country_Text__c,Region_Text__c 
                                                                from IRIS_Submission__c where id in : setSubIds]);
            
            //re-calculating the Submission Countries before updating the Submissions
            Iris_Utility.recalculateSubCountry(mapSubId_SubRec.keySet() , mapSubId_SubRec.values());
            // refrshing the Country Text field on submission
            Iris_Utility.refreshCountryTextField(mapSubId_SubRec);
            
            String sRegionText;
            for(IRIS_Submission_Region__c subRegion : lstUpdatedSubRegions){
                sRegionText = mapSubId_SubRec.get(subRegion.Compliance_Submission__c).Region_Text__c;
                sRegionText = sRegionText.replace(oldMapSubRegion.get(subRegion.id).Region_Name__c,
                                                         subRegion.Region_Name__c);
                sRegionText = sRegionText.removeEnd(';');
                mapSubId_SubRec.get(subRegion.Compliance_Submission__c).Region_Text__c = Iris_Utility.sortTheString(sRegionText);
            }
            Database.SaveResult[] updateResults = Database.update(mapSubId_SubRec.values() , false);
            if (updateResults != null){
                for (integer i = 0 ; i<updateResults.size(); i++){
                    if (!updateResults[i].isSuccess()){
                        for(Database.Error err : updateResults[i].getErrors())
                        {
                            mapSubId_SubRec.values()[i].addError(err.getMessage());
                        }
                    }
                }
            }
        }   
    }
    
    /* 
     * Method name : removeRegionTextField
     * Description : This method is used to remove Region from the text field when the related list is deleted.
     * Param - lstSubRegions : list of Regions
     * Returns :  null
    */
    
    public void removeRegionTextField(List<IRIS_Submission_Region__c> lstSubRegions){
        setSubIds = new Set<Id>();
        for(IRIS_Submission_Region__c subRegion : lstSubRegions){
            setSubIds.add(subRegion.Compliance_Submission__c);
        }
        mapSubId_SubRec = new Map<id,IRIS_Submission__c>([Select Country_Text__c,Region_Text__c 
                                                            from IRIS_Submission__c where id in : setSubIds]);
        
        //re-calculating the Submission Countries before updating the Submissions
        Iris_Utility.recalculateSubCountry(mapSubId_SubRec.keySet() , mapSubId_SubRec.values());
        // refrshing the Country Text field on submission
        Iris_Utility.refreshCountryTextField(mapSubId_SubRec);
        
        String sRegionText;
        for(IRIS_Submission_Region__c subRegion : lstSubRegions){
            sRegionText = mapSubId_SubRec.get(subRegion.Compliance_Submission__c).Region_Text__c;
            sRegionText = sRegionText.remove(subRegion.Region_Name__c);
            sRegionText = sRegionText.removeStart(';');
            sRegionText = sRegionText.removeEnd(';');
            sRegionText = sRegionText.replace(';;',';');
            mapSubId_SubRec.get(subRegion.Compliance_Submission__c).Region_Text__c = Iris_Utility.sortTheString(sRegionText);
        }
        Database.SaveResult[] updateResults = Database.update(mapSubId_SubRec.values() , false);
        if (updateResults != null){
            for (integer i = 0 ; i<updateResults.size(); i++){
                if (!updateResults[i].isSuccess()){
                    for(Database.Error err : updateResults[i].getErrors())
                    {
                        mapSubId_SubRec.values()[i].addError(err.getMessage());
                    }
                }
            }
        }
    }
    
    /* 
     * Method name : getUpdatedSubRegions
     * Description : This method is used to update countries in the country text field when related list is updated .
     * Param - lstSubRegions: list of Regions, oldMapSubRegion: map of id's and Regions.
     * Returns :  lstUpdatedSubRegions : list of updated Regions.
    */
    
    private List<IRIS_Submission_Region__c> getUpdatedSubRegions(List<IRIS_Submission_Region__c> lstSubRegions , 
                                                                            map<id,IRIS_Submission_Region__c> oldMapSubRegion){
        lstUpdatedSubRegions = new List<IRIS_Submission_Region__c>();
        setSubIds = new Set<Id>();
        for(IRIS_Submission_Region__c subRegion : lstSubRegions){
            if(subRegion.Region__c != oldMapSubRegion.get(subRegion.id).Region__c){
                lstUpdatedSubRegions.add(subRegion);
                setSubIds.add(subRegion.Compliance_Submission__c);
            }
        }
        return lstUpdatedSubRegions;
    }
}