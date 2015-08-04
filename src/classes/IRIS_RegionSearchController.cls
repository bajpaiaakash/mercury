/*
*  Classname : Iriss_RegionSearchController
*   Created By: Deloitte USI    
*   Created Date: 25-Mar-2014
*   Description: This class is used in Iriss_RegionSearchPage.
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/

public with sharing class IRIS_RegionSearchController{
    public List<RegionWrapper> lstRegionWrapp{set;get;}
    public transient String selectedRegionIds{set;get;}
    public transient String selectedRegionNames{set;get;}
    
    public IRIS_RegionSearchController()
    {
        // getting the earlier selected region ids (if any) from the URL
        selectedRegionIds = apexpages.currentpage().getparameters().get('regionIds');
        populateRegionWrapper();
    }
    
     /* 
     * Method name : populateRegionWrapper
     * Description : This method is used to populate list of Regions.
     * Param - No parameter 
     * Returns :  null
    */
    
    private void populateRegionWrapper(){
        List<IRIS_Region__c> lstRountries = [Select Name from IRIS_Region__c order by name limit :Limits.getLimitQueryRows()];
        if(lstRountries != null && lstRountries.size()>0){
            lstRegionWrapp = new List<RegionWrapper>();
            for(IRIS_Region__c region : lstRountries){
                if(String.isNotBlank(selectedRegionIds) && selectedRegionIds.containsIgnoreCase(region.id))
                    lstRegionWrapp.add(new RegionWrapper(region,true));
                else
                    lstRegionWrapp.add(new RegionWrapper(region,false));
            }
        }
    }
    
    /* 
     * Method name : saveResponse
     * Description : This method is used to save the Region details.
     * Param - No parameter 
     * Returns :  null
    */
    
    public void saveResponse()
    {
        selectedRegionIds = '';
        selectedRegionNames = '';
        // concatinating the selected region names and selected region ids
        for(RegionWrapper RegionWrap : lstRegionWrapp){
            if(RegionWrap.isSelected == true){
                selectedRegionIds += RegionWrap.region.id + ';' ;
                selectedRegionNames += RegionWrap.regionName + ';' ;
            }
        }
        // removing the last ';' from the name as name will ne displayed on the submission page in the region text field
        selectedRegionNames = selectedRegionNames.removeEnd(';');
    }
    
    /*
    *  Classname : RegionWrapper
    *  Description: This class is used to store the Regions which are selected. 
    */
    
    public class RegionWrapper{
        public IRIS_Region__c region{set;get;}
        // name of the region with single quotes escaped
        public string regionName{set;get;}
        public boolean isSelected{set;get;}
        RegionWrapper(IRIS_Region__c oRegion , boolean bIsSelected){
            region = oRegion;
            regionName = String.escapeSingleQuotes(region.name);
            isSelected = bIsSelected;
        }
    }
}