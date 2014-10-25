/*
*  Classname : Iriss_Utility 
*   Created By: Deloitte USI    
*   Created Date: 03-Mar-2014
*   Description: This class is used by different class contain commen method.
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/

public class IRIS_Utility{

    /* 
     * Method name : getProcessInstanceWorkitem
     * Description : This method is used for approval process.
     * Param - No parameter.
     * Returns :  void
    */
    
    public static ProcessInstanceWorkitem getProcessInstanceWorkitem(Id TargetObjId)
    {
        if(TargetObjId != null)
        {
            List<ProcessInstanceWorkitem> lstProcessInsWI = [Select ProcessInstanceId,ProcessInstance.TargetObjectId,  OriginalActorId, ActorId 
                           From ProcessInstanceWorkitem 
                           where ProcessInstance.TargetObjectId=: TargetObjId];
           if(lstProcessInsWI != null && lstProcessInsWI.size()>0)
           {
                return lstProcessInsWI[0];
           }
        }
        return null;
    }
    
    /* 
     * Method name : getAssociatedCountries
     * Description : This method is used populate countries for a selected region.
     * Param - No parameter.
     * Returns :  void
    */
    
    public static List<IRIS_Country__c> getAssociatedCountries(String selectedRegions)
    {
        if(String.isNotBlank(selectedRegions))
        {
            List<String> lstRegions = selectedRegions.split(';');
            List<IRIS_Region_Country__c> lstRegionCountry = [Select Country__c,Country__r.name from IRIS_Region_Country__c
                                                                 where Region__c in : lstRegions order by Country__r.name];
            if(lstRegionCountry != null && lstRegionCountry.size()>0)
            {
                Set<Id> associatedCountryIds = new Set<Id>();
                List<IRIS_Country__c> lstCountries = new List<IRIS_Country__c>();
                for(IRIS_Region_Country__c regionCountry : lstRegionCountry)
                {
                    if(associatedCountryIds.add(regionCountry.Country__c))
                    {
                        lstCountries.add(new IRIS_Country__c(name=regionCountry.Country__r.name, id = regionCountry.Country__c)) ;
                    }
                }
                return lstCountries;
            }   
        }
        return null;
    }
    
    /* 
     * Method name : getAssociatedRegions
     * Description : This method is used populate Regions for a selected Countries.
     * Param - No parameter.
     * Returns :  void
    */
    
    public static List<IRIS_Region__c> getAssociatedRegions(String selectedCountries)
    {
        if(String.isNotBlank(selectedCountries))
        {
            List<String> lstCountries = selectedCountries.split(';');
            List<IRIS_Region_Country__c> lstRegionCountry = [Select Region__c,Region__r.name from IRIS_Region_Country__c
                                                                 where Country__c in : lstCountries order by Region__r.name];
            if(lstRegionCountry != null && lstRegionCountry.size()>0)
            {
                Set<Id> associatedRegionIds = new Set<Id>();
                List<IRIS_Region__c> lstRegions = new List<IRIS_Region__c>();
                for(IRIS_Region_Country__c regionCountry : lstRegionCountry)
                {
                    if(associatedRegionIds.add(regionCountry.Region__c))
                    {
                        lstRegions.add(new IRIS_Region__c(name=regionCountry.Region__r.name, id = regionCountry.Region__c)) ;
                    }
                }
                return lstRegions;
            }
        }
        return null;
    }
    
    /* 
     * Method name : sortTheString
     * Description : This method is used to spit the string, then sort it in alphabetical order and the again converage it back to one string.
     * Param - No parameter.
     * Returns :  The sorted string
    */
    public static string sortTheString(String stringToSort){
        List<String> lstStrings = stringToSort.split(';');
        lstStrings.sort();
        String strToReturn = '';
        for(String str : lstStrings){
            strToReturn += str + ';';
        }
        strToReturn = strToReturn.removeEnd(';');
        return strToReturn;
    }
    
    /* 
     * Method name : recalculateSubRegion
     * Description : This method is used to re-calculate the submission regions based on the updated/deleted submission countries
     * Param - setSubIds : set of submission ids , lstSubmissions : list of submission records
     * Returns :  void
    */
    public static void recalculateSubRegion(Set<Id> setSubIds, List<IRIS_Submission__c> lstSubmissions){
        // map of existing Submission region with the key as the combination of submission id and reion id
        Map<String,IRIS_Submission_Region__c> mapExistingSubRegion = new Map<String,IRIS_Submission_Region__c>();
        // map of existing submission id with the associated country ids 
        Map<id,Set<Id>> mapSubId_countryIds = new map<Id,Set<Id>>();
        // the map used for mapping the country id with the region ids
        map<Id,set<Id>> mapCountryId_regionIds = new map<Id,set<Id>>();
        // Set of expected submission regions
        // the string stored is a combination of submission record id and the region id
        set<String> expectedSubRegions = new Set<String>();
        // populating mapExistingSubRegion
        for(IRIS_Submission_Region__c oSubRegion : [Select Region__c,Compliance_Submission__c 
                                                        from IRIS_Submission_Region__c
                                                        where Compliance_Submission__c in : setSubIds]){
            mapExistingSubRegion.put(oSubRegion.Compliance_Submission__c + ';' + oSubRegion.Region__c , oSubRegion);
        } 
        // populating mapSubId_countryIds
        Set<Id> setAllCountryIds = new Set<Id>();
        Set<Id> tempSetIds;
        for(IRIS_Submission_Country__c subCountry : [Select Country__c, Compliance_Submission__c 
                                                        from IRIS_Submission_Country__c 
                                                        where Compliance_Submission__c in : setSubIds]){
            tempSetIds = mapSubId_countryIds.get(subCountry.Compliance_Submission__c);
            if(tempSetIds == null){
                tempSetIds = new Set<Id>();
                mapSubId_countryIds.put(subCountry.Compliance_Submission__c , tempSetIds);
            }
            tempSetIds.add(subCountry.Country__c);
            setAllCountryIds.add(subCountry.Country__c);
        }
        // populating mapCountryId_regionIds
        if(setAllCountryIds.size()>0){
            for(IRIS_Region_Country__c regionCountry : [Select Country__c,Region__c 
                                                        from IRIS_Region_Country__c 
                                                        where Country__c in : setAllCountryIds]){
                tempSetIds = mapCountryId_regionIds.get(regionCountry.Country__c); 
                if(tempSetIds == null){
                    tempSetIds = new Set<Id>();
                    mapCountryId_regionIds.put(regionCountry.Country__c , tempSetIds);
                }
                tempSetIds.add(regionCountry.Region__c);
            }
        }
        
        // populating expectedSubRegions and finding the subRegions to delete and subRegions to insert
        if(mapSubId_countryIds.size()>0 && mapCountryId_regionIds.size()>0){
            for(Id subId : mapSubId_countryIds.keyset()){
                if(mapSubId_countryIds.get(subId) != null){
                    for(Id countryId : mapSubId_countryIds.get(subId)){
                        if(mapCountryId_regionIds.get(countryId) != null){
                            for(Id regionId : mapCountryId_regionIds.get(countryId)){
                                expectedSubRegions.add(subId + ';' + regionId);
                            }   
                        }
                    }   
                }
            }
        }
        List<IRIS_Submission_Region__c> subRegionToDelete = new List<IRIS_Submission_Region__c>();
        List<IRIS_Submission_Region__c> subRegionToInsert = new List<IRIS_Submission_Region__c>();
        // calculating the submission regions to be deleted.
        for(String existingSubRegion : mapExistingSubRegion.keySet()){
            if(!expectedSubRegions.contains(existingSubRegion)){
                subRegionToDelete.add(mapExistingSubRegion.get(existingSubRegion));
            }
        }
        // calculating the submission regions to be inserted.
        expectedSubRegions.removeAll(mapExistingSubRegion.keySet());
        for(String expectedSubRegion : expectedSubRegions){
            subRegionToInsert.add(new IRIS_Submission_Region__c(
                    Compliance_Submission__c = expectedSubRegion.subString(0,expectedSubRegion.indexOf(';')),
                    Region__c = expectedSubRegion.subString(expectedSubRegion.indexOf(';')+1,expectedSubRegion.length())));
        }
        try{
            if(subRegionToDelete.size()>0){
                delete subRegionToDelete;
            }
            if(subRegionToInsert.size()>0){
                insert subRegionToInsert;
            }
            
        }
        catch(Exception exp){
            for(IRIS_Submission__c oSubmission : lstSubmissions)
                oSubmission.addError(Label.Iriss_Error_calculating_Submission_regions);
        }
    }
    
    /* 
     * Method name : refreshRegionTextField
     * Description : This method is used to re-calculate the region text field based on the updated/deleted submission regions
     * Param - mapSubId_SubRec : map of submission id and Submission record
     * Returns :  void
    */
    public static void refreshRegionTextField(map<id,IRIS_Submission__c> mapSubId_SubRec){
        // clearing the region text field
        for(IRIS_Submission__c oSubmission : mapSubId_SubRec.values()){
            oSubmission.Region_Text__c = '';  
        }
        for(IRIS_Submission_Region__c subRegion : [Select Region_Name__c, Compliance_Submission__c 
                                                        from IRIS_Submission_Region__c 
                                                        where Compliance_Submission__c in : mapSubId_SubRec.keySet()
                                                        order by Region__r.name ]){
            if(String.isBlank(mapSubId_SubRec.get(subRegion.Compliance_Submission__c).Region_Text__c)){
                mapSubId_SubRec.get(subRegion.Compliance_Submission__c).Region_Text__c += subRegion.Region_Name__c;
            }
            else{
                mapSubId_SubRec.get(subRegion.Compliance_Submission__c).Region_Text__c += ';' + subRegion.Region_Name__c; 
            }
        }
    }
    
    /* 
     * Method name : recalculateSubCountry
     * Description : This method is used to re-calculate the submission countries based on the updated/deleted submission regions
     * Param - setSubIds : set of submission ids , lstSubmissions : list of submission records
     * Returns :  void
    */
    public static void recalculateSubCountry(Set<Id> setSubIds, List<IRIS_Submission__c> lstSubmissions){
        // map of existing Submission country with the key as the combination of submission id and country id
        Map<String,IRIS_Submission_Country__c> mapExistingSubCountry = new Map<String,IRIS_Submission_Country__c>();
        // map of existing submission id with the associated region ids 
        Map<id,Set<Id>> mapSubId_regionIds = new map<Id,Set<Id>>();
        // the map used for mapping the region id with the country ids
        map<Id,set<Id>> mapRegionId_Countryds = new map<Id,set<Id>>();
        // Set of expected submission countries
        // the string stored is a combination of submission record id and the country id
        set<String> expectedSubCountrys = new Set<String>();
        // populating mapExistingSubCountry
        for(IRIS_Submission_Country__c oSubCountry : [Select Country__c,Compliance_Submission__c 
                                                        from IRIS_Submission_Country__c
                                                        where Compliance_Submission__c in : setSubIds]){
            mapExistingSubCountry.put(oSubCountry.Compliance_Submission__c + ';' + oSubCountry.Country__c , oSubCountry);
        } 
        // populating mapSubId_regionIds
        Set<Id> setAllRegionIds = new Set<Id>();
        Set<Id> tempSetIds;
        for(IRIS_Submission_Region__c subRegion : [Select Region__c, Compliance_Submission__c 
                                                        from IRIS_Submission_Region__c 
                                                        where Compliance_Submission__c in : setSubIds]){
            tempSetIds = mapSubId_regionIds.get(subRegion.Compliance_Submission__c);
            if(tempSetIds == null){
                tempSetIds = new Set<Id>();
                mapSubId_regionIds.put(subRegion.Compliance_Submission__c , tempSetIds);
            }
            tempSetIds.add(subRegion.Region__c);
            setAllRegionIds.add(subRegion.Region__c);
        }
        // populating mapRegionId_Countryds
        if(setAllRegionIds.size()>0){
            for(IRIS_Region_Country__c regionCountry : [Select Region__c,Country__c 
                                                        from IRIS_Region_Country__c 
                                                        where Region__c in : setAllRegionIds]){
                tempSetIds = mapRegionId_Countryds.get(regionCountry.Region__c);   
                if(tempSetIds == null){
                    tempSetIds = new Set<Id>();
                    mapRegionId_Countryds.put(regionCountry.Region__c , tempSetIds);
                }
                tempSetIds.add(regionCountry.Country__c);
            }
        }
        
        // populating expectedSubCountrys and finding the subCountrys to delete and subCountrys to insert
        if(mapSubId_regionIds.size()>0 && mapRegionId_Countryds.size()>0){
            for(Id subId : mapSubId_regionIds.keyset()){
                if(mapSubId_regionIds.get(subId) != null){
                    for(Id regionId : mapSubId_regionIds.get(subId)){
                        if(mapRegionId_Countryds.get(regionId) != null){
                            for(Id countryId : mapRegionId_Countryds.get(regionId)){
                                expectedSubCountrys.add(subId + ';' + countryId);
                            }
                        }
                    }
                }
                
            }
        }
        List<IRIS_Submission_Country__c> subCountryToDelete = new List<IRIS_Submission_Country__c>();
        List<IRIS_Submission_Country__c> subCountryToInsert = new List<IRIS_Submission_Country__c>();
        // calculating the submission countries to be deleted.
        for(String existingSubCountry : mapExistingSubCountry.keySet()){
            if(!expectedSubCountrys.contains(existingSubCountry)){
                subCountryToDelete.add(mapExistingSubCountry.get(existingSubCountry));
            }
        }
        // calculating the submission countries to be inserted.
        expectedSubCountrys.removeAll(mapExistingSubCountry.keySet());
        for(String expectedSubCountry : expectedSubCountrys){
            subCountryToInsert.add(new IRIS_Submission_Country__c(
                    Compliance_Submission__c = expectedSubCountry.subString(0,expectedSubCountry.indexOf(';')),
                    Country__c = expectedSubCountry.subString(expectedSubCountry.indexOf(';')+1,expectedSubCountry.length())));
        }
        try{
            if(subCountryToDelete.size()>0){
                delete subCountryToDelete;
            }
            if(subCountryToInsert.size()>0){
                insert subCountryToInsert;
            }
            
        }
        catch(Exception exp){
            for(IRIS_Submission__c oSubmission : lstSubmissions)
                oSubmission.addError(Label.Iriss_Error_calculating_Submission_countries);
        }
    }
    
    /* 
     * Method name : refreshCountryTextField
     * Description : This method is used to re-calculate the country text field based on the updated/deleted submission countries
     * Param - mapSubId_SubRec : map of submission id and Submission record
     * Returns :  void
    */
    public static void refreshCountryTextField(map<id,IRIS_Submission__c> mapSubId_SubRec){
        // clearing the region text field
        for(IRIS_Submission__c oSubmission : mapSubId_SubRec.values()){
            oSubmission.Country_Text__c = ''; 
        }
        for(IRIS_Submission_Country__c subCountry : [Select Country_Name__c, Compliance_Submission__c 
                                                        from IRIS_Submission_Country__c 
                                                        where Compliance_Submission__c in : mapSubId_SubRec.keySet()
                                                        order by Country__r.name ]){
            if(String.isBlank(mapSubId_SubRec.get(subCountry.Compliance_Submission__c).Country_Text__c)){
                mapSubId_SubRec.get(subCountry.Compliance_Submission__c).Country_Text__c += subCountry.Country_Name__c;   
            }
            else{
                mapSubId_SubRec.get(subCountry.Compliance_Submission__c).Country_Text__c += ';' + subCountry.Country_Name__c;
            }
        }
    }
    
    public static user CreateUserForTestMethods() {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName=math.random()+'@testorg.com');
        return u;
    }
}