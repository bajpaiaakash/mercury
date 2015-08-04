/*
*  Classname : Iriss_CountrySearchController
*  Created By: Deloitte USI    
*  Created Date: 25-Mar-2014
*  Description: This class is used in Iriss_CountrySearchPage.
*  Version : 0.1 
*  Change Log
*  Version     Description                         Updated By
*    
*/

public with sharing class IRIS_CountrySearchController{
    
    public List<CountryWrapper> lstCounWrapp{set;get;}
    public transient String selectedCountryIds{set;get;}
    public transient String selectedCountryNames{set;get;}
    
    public IRIS_CountrySearchController()
    {
        // getting the earlier selected country ids (if any) from the URL
        selectedCountryIds = apexpages.currentpage().getparameters().get('countryIds');
        populateCountryWrapper();
    }
    
    /* 
      * Method name : populateCountryWrapper
      * Description : This method is used to populate list of Countries.
      * Param - No parameter 
      * Returns :  null
    */
    
    private void populateCountryWrapper(){
        List<IRIS_Country__c> lstCountries = [Select Name from IRIS_Country__c order by name limit :Limits.getLimitQueryRows()];
        if(lstCountries != null && lstCountries.size()>0){
            lstCounWrapp = new List<CountryWrapper>();
            for(IRIS_Country__c country : lstCountries){
                // if the country was ealier selected, set the isSelected boolean in the wrapper as true
                if(String.isNotBlank(selectedCountryIds) && selectedCountryIds.containsIgnoreCase(country.id))
                    lstCounWrapp.add(new CountryWrapper(country,true));
                // if the country was ealier not selected, set the isSelected boolean in the wrapper as false
                else
                    lstCounWrapp.add(new CountryWrapper(country,false));
            }
        }
    }
    
    /* 
     * Method name : saveResponse
     * Description : This method is used to save the Country details.
     * Param - No parameter 
     * Returns :  null
    */
    
    public void saveResponse()
    {
        selectedCountryIds = '';
        selectedCountryNames = '';
        // concatinating the selected country names and selected country ids
        for(CountryWrapper countWrap : lstCounWrapp){
            if(countWrap.isSelected == true){
                selectedCountryIds += countWrap.country.id + ';' ;
                selectedCountryNames += countWrap.countryName + ';' ;
            }
        }
        // removing the last ';''
        selectedCountryNames = selectedCountryNames.removeEnd(';');
    }
    
    /*
    *  Classname : CountryWrapper
    *  Description: This class is used to store the Countries which are selected. 
    */
    
    public class CountryWrapper{
        public IRIS_Country__c country{set;get;}
        // name of the country with single quotes escaped
        public string countryName{set;get;}
        public boolean isSelected{set;get;}
        CountryWrapper(IRIS_Country__c oCountry , boolean bIsSelected){
            country = oCountry;
            countryName = String.escapeSingleQuotes(country.name);
            isSelected = bIsSelected;
        }
    }
}