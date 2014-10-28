/*
*  Classname : Iriss_Submission_Country_Trigger_Helper
*   Created By: Deloitte USI    
*   Created Date: 25-Mar-2014
*   Description: This class is used by trigger Iriss_Submission_Country_BD_BU to update the Country text field on the respective Submissions
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/

public with sharing class IRIS_Submission_Country_Trigger_Helper{
    
    private List<IRIS_Submission_Country__c> lstUpdatedSubCountries{set;get;} 
    private set<Id> setSubIds{set;get;}
    private map<id,IRIS_Submission__c> mapSubId_SubRec{set;get;}
    public static boolean hasTakenCareOf{set;get;} 
    
    public void updateCountryTextField(List<IRIS_Submission_Country__c> lstSubCountries , map<id,IRIS_Submission_Country__c> oldMapSubCountry){
        // get only the submission countries which have the Country updated
        getUpdatedSubCountries(lstSubCountries , oldMapSubCountry);
        if(lstUpdatedSubCountries != null && lstUpdatedSubCountries.size()>0){
            mapSubId_SubRec = new Map<id,IRIS_Submission__c>([Select Country_Text__c,Region_Text__c 
                                                                from IRIS_Submission__c where id in : setSubIds]);
            //re-calculating the Submission regions before updating the Submissions
            Iris_Utility.recalculateSubRegion(mapSubId_SubRec.keySet() , mapSubId_SubRec.values());
            // refrshing the Region Text field on submission
            Iris_Utility.refreshRegionTextField(mapSubId_SubRec);
            
            String sCountryText;
            for(IRIS_Submission_Country__c subCountry : lstUpdatedSubCountries){
                sCountryText = mapSubId_SubRec.get(subCountry.Compliance_Submission__c).Country_Text__c;
                if(subCountry.Country_Name__c !=null && subCountry.Country_Name__c !=''){
                sCountryText = sCountryText.replace(oldMapSubCountry.get(subCountry.id).Country_Name__c,
                                                         subCountry.Country_Name__c);
                }
                sCountryText = sCountryText.removeEnd(';');
                mapSubId_SubRec.get(subCountry.Compliance_Submission__c).Country_Text__c = Iris_Utility.sortTheString(sCountryText);
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
     * Method name : removeCountryTextField
     * Description : This method is used to remove country from the text field when the related list is deleted.
     * Param - lstSubCountries : list of Countries
     * Returns :  null
    */
    
    public void removeCountryTextField(List<IRIS_Submission_Country__c> lstSubCountries){
        setSubIds = new Set<Id>();
        for(IRIS_Submission_Country__c subCountry : lstSubCountries){
            setSubIds.add(subCountry.Compliance_Submission__c);
        }
        mapSubId_SubRec = new Map<id,IRIS_Submission__c>([Select Country_Text__c,Region_Text__c 
                                                            from IRIS_Submission__c where id in : setSubIds]);
        
        //re-calculating the Submission regions before updating the Submissions
        Iris_Utility.recalculateSubRegion(mapSubId_SubRec.keySet() , mapSubId_SubRec.values());
        // refrshing the Region Text field on submission
        Iris_Utility.refreshRegionTextField(mapSubId_SubRec);
        
        String sCountryText;
        for(IRIS_Submission_Country__c subCountry : lstSubCountries){
            sCountryText = mapSubId_SubRec.get(subCountry.Compliance_Submission__c).Country_Text__c;
            if(subCountry.Country_Name__c !=null && subCountry.Country_Name__c !=''){
            sCountryText = sCountryText.remove(subCountry.Country_Name__c);
            }
            sCountryText = sCountryText.removeStart(';');
            sCountryText = sCountryText.removeEnd(';');
            sCountryText = sCountryText.replace(';;',';');
            mapSubId_SubRec.get(subCountry.Compliance_Submission__c).Country_Text__c = Iris_Utility.sortTheString(sCountryText);
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
     * Method name : getUpdatedSubCountries
     * Description : This method is used to update countries in the country text field when related list is updated .
     * Param - lstSubCountries : list of Countries, oldMapSubCountry: map of id's and countries.
     * Returns :  lstUpdatedSubCountries : list of updated countries.
    */
    
    private List<IRIS_Submission_Country__c> getUpdatedSubCountries(List<IRIS_Submission_Country__c> lstSubCountries , 
                                                                            map<id,IRIS_Submission_Country__c> oldMapSubCountry){
        lstUpdatedSubCountries = new List<IRIS_Submission_Country__c>();
        setSubIds = new Set<Id>();
        for(IRIS_Submission_Country__c subCountry : lstSubCountries){
            if(subCountry.Country__c != oldMapSubCountry.get(subCountry.id).Country__c){
                lstUpdatedSubCountries.add(subCountry);
                setSubIds.add(subCountry.Compliance_Submission__c);
            }
        }
        return lstUpdatedSubCountries;
    }
    
}