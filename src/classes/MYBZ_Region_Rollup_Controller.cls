/*
*@ Class Name                                                    : MYBZ_Region_Rollup_Controller
*@ Description                                                   : Controller class to prepare JSONs to share data queried from various objects to Angular JS .
Class for retrieving salesforce data in the form of a string and returning as a JSON object via a remote action.
*@ CreatedBy                                                     : Neelam Dalwani
*@ CreatedOn                                                     : 09-30-2014
*                    
*/

global with sharing class MYBZ_Region_Rollup_Controller
{
    global static Id UserId;
    global static String Role{get;set;}
    global static String GlobalId{get;set;}
    global static String datetimeStamp{get;set;}
    global static String uname{get;set;}
    global static String Page{get;set;}
    
    static String JsonString;
    static Decimal PercentageChangeTRx = 0;
    static Decimal PercentageChangeDDDUnits = 0;
    static Decimal PercentageChangeDDDDollars = 0;
    
    
    
    static JSONGenerator generator;
    static List<MYBZ_Market_Share__c> productTrendsList = new  List<MYBZ_Market_Share__c>();
    
    
    static List<MYBZ_Product_Trend_Detail__c> TrendsDetailsList = new List<MYBZ_Product_Trend_Detail__c>();
    
    
    static List<MYBZ_Market_Share__c> marketShareList = new List<MYBZ_Market_Share__c>();  
    
    static List<MYBZ_Target_Goal__c> targetGoalList = new List<MYBZ_Target_Goal__c>();
    static Set<Decimal> targetGoalYear = new Set<Decimal>();
    static Map<Decimal, Map<Decimal, List<MYBZ_Target_Goal__c>>> YearAndMonthTargetGoalMap = new Map<Decimal, Map<Decimal, List<MYBZ_Target_Goal__c>>>();
    
    static List<MYBZ_CallPlanningProductJunction__c> CallPlanningsList = new List<MYBZ_CallPlanningProductJunction__c>();
    static List<MYBZ_Call__c> CallsList = new List<MYBZ_Call__c>();
    
    global MYBZ_Region_Rollup_Controller(){
        fetchUserInfo();
    }
    /* 
* @Method Name                    :  fetchUserInfo
* @Description                    :  Method used to get logged in user's Role and Global id as it forms the basis to fetch 
user related data for reporting .                                        
* @Return Type                    :  void
* @Param                          :  
*/    
    global static void fetchUserInfo(){
        UserId = UserInfo.getUserId();      
        User userObj = [SELECT name,Prsnl_Nbr_GLBL__c, MYBZ_Role__c, MYBZ_Reporting_ID__c FROM User WHERE Id =:UserId];
        if(userObj!=null){
            Role = userObj.MYBZ_Role__c;
            if(Role==System.Label.MYBZ_AccountManager){
                GlobalId=userObj.MYBZ_Reporting_ID__c;
            }
            else{
                GlobalId = userObj.Prsnl_Nbr_GLBL__c;
            }
            uname=userObj.name;
        }
        
        
    }
    
    /* 
* @Method Name                    :  countUsageMetrics
* @Description                    :  method is used to create a new record in usage metrics report object everytime a user
opens up the report with details like datetime,globalid, type of report etc. getting stamped each time.
This object is later used to report on User activity on this application.                                        
* @Return Type                    :  void
* @Param                          :  
*/
    
    public void countUsageMetrics()
    {
        try
        {
            MYBZ_Usage_Metric_Report__c metricsCount =new MYBZ_Usage_Metric_Report__c();
            metricsCount.DateTimeStamp__c=datetimeStamp;
            metricsCount.Global_Id__c=GlobalId;
            metricsCount.Page__c=Page;
            insert metricsCount;
        }
        catch(Exception E) 
        {
            system.debug('Exception occurred during execution of countUsageMetrics method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
        }
        
        
    }
    /* 
* @Method Name                    :  alignment
* @Description                    :  JavaScript remoting to allow Alignment record to be retrieved from Salesforce in the form of a JSON object to show alignment dropdown in territory picker.                                        
* @Return Type                    :  object
* @Param                          :  
*/
    
    @RemoteAction 
    global static Object alignment()
    {
        try
        {
            //Call fetch user function so that Role and Global id value is available in this method.
            fetchUserInfo();
            
             //Returns a new JSON generator.
            generator = JSON.createGenerator(true);
            
            //Set of unique Region id's .
            Set<Id> regionIds = new Set<Id>();
            
            //Set of unique district id's.
            Set<Id> districtIds = new Set<Id>();
            
            //Checking if the division record exist. There will be only one Division record.
            MYBZ_IHS_Division__c divisionObj = [SELECT Id, Name FROM MYBZ_IHS_Division__c LIMIT 1];
            if(divisionObj==null)
            {
                return null;
            }
            else
            {
                //Map of Region name and its global id.
                Map<String, String> RegionNameAndGlobalIdMap = new Map<String, String>();
                //Map of Region name and its associated districts.
                Map<String, Set<String>> RegionNameAndDistrictMap = new Map<String, Set<String>>();
                //Map of District Name and its Global id.
                Map<String, String> DistrictNameAndGlobalIdMap = new Map<String, String>();
                //Map of District name and its associated territory.
                Map<String, Set<String>> DistrictNameAndTerritoryMap = new Map<String, Set<String>>();
                //Map of Territory and its Global id.
                Map<String, String> TerritoryNameAndGlobalIdMap = new Map<String, String>();
               
                    for(MYBZ_Region_Rollup__c regionObj : [SELECT Id, Region__r.Name, Global_Id__c, Alignment_Level__c FROM MYBZ_Region_Rollup__c WHERE Alignment_Level__c = :System.Label.MYBZ_Region]){
                        if(!RegionNameAndGlobalIdMap.containsKey(regionObj.Region__r.Name)){
                            RegionNameAndGlobalIdMap.put(regionObj.Region__r.Name, regionObj.Global_Id__c);
                        }
                    }
             
                    for(MYBZ_Region_Rollup__c districtObj : [SELECT Id, Region__r.Name, District__r.Name, Global_Id__c, Alignment_Level__c FROM MYBZ_Region_Rollup__c WHERE Alignment_Level__c = :System.Label.MYBZ_District ]){
                        if(!RegionNameAndDistrictMap.containsKey(districtObj.Region__r.Name)){
                            Set<String> districtNames = new Set<String>();
                            districtNames.add(districtObj.District__r.Name);
                            RegionNameAndDistrictMap.put(districtObj.Region__r.Name, districtNames);
                        }
                        else{
                            RegionNameAndDistrictMap.get(districtObj.Region__r.Name).add(districtObj.District__r.Name);
                        }
                        if(!DistrictNameAndGlobalIdMap.containsKey(districtObj.District__r.Name)){
                            DistrictNameAndGlobalIdMap.put(districtObj.District__r.Name, districtObj.Global_Id__c);
                        }
                    }
             
                    for(MYBZ_Region_Rollup__c territoryObj : [SELECT Id, Territory__r.Name, District__r.Name, Global_Id__c, Alignment_Level__c FROM MYBZ_Region_Rollup__c WHERE Alignment_Level__c = :System.Label.MYBZ_Territory ]){
                        if(!DistrictNameAndTerritoryMap.containsKey(territoryObj.District__r.Name)){
                            Set<String> territoryNames = new Set<String>();
                            territoryNames.add(territoryObj.Territory__r.Name);
                            DistrictNameAndTerritoryMap.put(territoryObj.District__r.Name, territoryNames);
                        }
                        else{
                            DistrictNameAndTerritoryMap.get(territoryObj.District__r.Name).add(territoryObj.Territory__r.Name);
                        }
                        if(!TerritoryNameAndGlobalIdMap.containsKey(territoryObj.Territory__r.Name)){
                            TerritoryNameAndGlobalIdMap.put(territoryObj.Territory__r.Name, territoryObj.Global_Id__c);
                        }
                    }
             
                if(!RegionNameAndGlobalIdMap.isEmpty() && !RegionNameAndDistrictMap.isEmpty() && !DistrictNameAndGlobalIdMap.isEmpty() && !DistrictNameAndTerritoryMap.isEmpty() && !TerritoryNameAndGlobalIdMap.isEmpty()){
                    generator.writeStartArray();
                    for(String regionName : RegionNameAndGlobalIdMap.keySet()){
                        //Writes the starting marker of a JSON Object.
                        generator.writeStartObject();
                        //Start of writing the JSON fields.
                        generator.writeStringField(System.Label.MYBZ_Name,regionName);
                        String regionGlobalId = RegionNameAndGlobalIdMap.get(regionName);
                        if(regionGlobalId == null || regionGlobalId == ''){
                            generator.writeNullField(System.Label.MYBZ_globalID); 
                        }
                        else{
                            generator.writeStringField(System.Label.MYBZ_globalID,regionGlobalId);
                        }
                        if(RegionNameAndDistrictMap.containsKey(regionName)){
                            generator.writeFieldName(System.Label.MYBZ_children);
                            
                            generator.writeStartArray();
                            for(String districtName : RegionNameAndDistrictMap.get(regionName)){
                                
                                //Writes the starting marker of a JSON Object.
                                generator.writeStartObject();
                                generator.writeStringField(System.Label.MYBZ_Name,districtName);
                                String districtGlobalId = DistrictNameAndGlobalIdMap.get(districtName);
                                if(districtGlobalId == null || districtGlobalId == ''){
                                    generator.writeNullField(System.Label.MYBZ_globalID); 
                                }
                                else{
                                    generator.writeStringField(System.Label.MYBZ_globalID,districtGlobalId);
                                }
                                if(DistrictNameAndTerritoryMap.containsKey(districtName)){
                                    generator.writeFieldName(System.Label.MYBZ_children);
                                    
                                    //Writes the starting marker of a JSON Array.
                                    generator.writeStartArray();
                                    for(String territoryName : DistrictNameAndTerritoryMap.get(districtName)){
                                        generator.writeStartObject();
                                        generator.writeStringField(System.Label.MYBZ_Name,territoryName);
                                        String territoryGlobalId = TerritoryNameAndGlobalIdMap.get(territoryName);
                                        if(territoryGlobalId == null || territoryGlobalId == ''){
                                            generator.writeNullField(System.Label.MYBZ_globalID); 
                                        }   
                                        else
                                        {    
                                            generator.writeStringField(System.Label.MYBZ_globalID,territoryGlobalId);
                                        }
                                        generator.writeEndObject();
                                    }
                                    generator.writeEndArray();
                                }
                                generator.writeEndObject();
                            }
                            //Writes the ending marker of a JSON Array.
                            generator.writeEndArray();
                        }
                        //Writes the ending marker of a JSON Object.
                        generator.writeEndObject();
                    }
                    generator.writeEndArray();
                }
                String sdata = generator.getAsString();
                System.debug('--Alignment'+sdata );
                Object obj = Json.deserializeUntyped(sdata);
                return obj;
            }
        }    
        catch(Exception E) 
        {
            system.debug('Exception occurred during execution of Alignment method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
    }
    /* 
* @Method Name                    :  productTrendsUsingPicker
* @Description                    :  JavaScript remoting to allow Product Trends records for each month to be retrieved from Salesforce in the form of a JSON object 
*                                    in the presence of a territory picker.                                      
* @Return Type                    :  object
* @Param                          :  Region - The region associated to the territory selected, District - The district associated to the territory selected
Territory - The territory selected via a territory picker. 
*/    
    @RemoteAction 
    global static Object productTrendsUsingPicker(String region, String district, String territory)
    {
        try
        {  
            fetchUserInfo();
            if((Role == System.Label.MYBZ_MajorMarketManager || Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager || Role == System.Label.MYBZ_SuperUser) && district !=null && district !=''){
                productTrendsList.clear();
                productTrendsList = [SELECT Id, Global_ID__c, Region__c, District__c, Owner__c, lillyProduct__c, Market__c, Month__c, Year__c, Product__r.Name, TRx__c, percentageChangeFromPreviousMonth__c,Previous_Month_TRx__c, DDD_Dollars__c,DDD_Units__c,Previous_DDD_Dollars__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE District__r.Name =:district AND Territory__c = null AND Owner__c = :System.Label.MYBZ_LILLY AND lillyProduct__c = true ORDER BY Month__c, Year__c ASC,Market__c];
            }
            if((Role == System.Label.MYBZ_MajorMarketManager || Role == System.Label.MYBZ_SuperUser) && region !=null && region !='' && (district == null || district == '')){
                productTrendsList.clear();
                
                productTrendsList = [SELECT Id, Global_ID__c, Region__c, District__c, Owner__c, lillyProduct__c, Market__c, Month__c, Year__c, Product__r.Name, TRx__c, percentageChangeFromPreviousMonth__c,Previous_Month_TRx__c, DDD_Dollars__c,DDD_Units__c,Previous_DDD_Dollars__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE Region__r.Name =: region AND District__c = null AND Owner__c = :System.Label.MYBZ_LILLY AND lillyProduct__c = true ORDER BY Month__c, Year__c ASC,Market__c];
            }
            if((Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager  || Role == System.Label.MYBZ_SuperUser) && territory !=null && territory !=''){
                productTrendsList.clear();
                productTrendsList = [SELECT Id, Global_ID__c, Region__c, District__c, Owner__c, lillyProduct__c, Market__c, Month__c, Year__c, Product__r.Name, TRx__c, percentageChangeFromPreviousMonth__c,Previous_Month_TRx__c, DDD_Dollars__c,DDD_Units__c,Previous_DDD_Dollars__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE Territory__r.Name =:territory AND Owner__c = :System.Label.MYBZ_LILLY AND lillyProduct__c = true ORDER BY Month__c, Year__c ASC,Market__c];
            }
            
            
            
        }
        catch(Exception E) 
        {
            system.debug('Exception occurred during execution of ProductTrends method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
        Object ProductTrendsObject =productTrendsProcessor();
        return ProductTrendsObject;
        
    }
    
    /* 
* @Method Name                    :  productTrends
* @Description                    :  JavaScript remoting to allow Product Trends records for each month to be retrieved from Salesforce in the form of a JSON object 
*                                    in the absence of a territory picker.                                           
* @Return Type                    :  object
* @Param                          :   
*/
    
    @RemoteAction
    global static Object productTrends()
    {
        
        try
        {   
            fetchUserInfo();
            if(Role == System.Label.MYBZ_SalesRepresentative){
                productTrendsList.clear();
                productTrendsList = [SELECT Id, Global_ID__c, Region__c, District__c, Owner__c, lillyProduct__c, Market__c, Month__c, Year__c, Product__r.Name, TRx__c, percentageChangeFromPreviousMonth__c,Previous_Month_TRx__c, DDD_Dollars__c,DDD_Units__c,Previous_DDD_Dollars__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE Global_Id__c =:GlobalId AND Owner__c = :System.Label.MYBZ_LILLY AND lillyProduct__c = true ORDER BY Month__c, Year__c ASC,Market__c];
            }
            if(Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager ){
                productTrendsList.clear();
                productTrendsList = [SELECT Id, Global_ID__c, Region__c, District__c, Owner__c, lillyProduct__c, Month__c, Year__c, Product__r.Name, TRx__c, percentageChangeFromPreviousMonth__c, Previous_Month_TRx__c, DDD_Units__c,DDD_Dollars__c,Previous_DDD_Dollars__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE Global_Id__c =:GlobalId AND Owner__c = :System.Label.MYBZ_LILLY AND lillyProduct__c = true ORDER BY Month__c, Year__c ASC,Market__c];
            }
            if(Role == System.Label.MYBZ_MajorMarketManager){
                productTrendsList.clear();
                productTrendsList = [SELECT Id, Global_ID__c, Region__c, District__c, Owner__c, lillyProduct__c, Month__c, Year__c, Product__r.Name, TRx__c, percentageChangeFromPreviousMonth__c, Previous_Month_TRx__c, DDD_Units__c,DDD_Dollars__c,Previous_DDD_Dollars__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE Global_Id__c =:GlobalId AND Owner__c = :System.Label.MYBZ_LILLY AND lillyProduct__c = true ORDER BY Month__c, Year__c ASC,Market__c];
            }
            if(Role == System.Label.MYBZ_SuperUser){
                productTrendsList.clear();
                
                    MYBZ_Region__c reg=[Select id from MYBZ_Region__c where Name =: System.Label.MYBZ_defaultRegion ];
                
                    productTrendsList = [SELECT Id, Global_ID__c, Region__c, District__c, Owner__c, lillyProduct__c, Month__c, Year__c, Product__r.Name, TRx__c, percentageChangeFromPreviousMonth__c, Previous_Month_TRx__c, DDD_Units__c,DDD_Dollars__c,Previous_DDD_Dollars__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE Region__c =:reg.Id and district__c=null AND Owner__c = :System.Label.MYBZ_LILLY AND lillyProduct__c = true ORDER BY Month__c, Year__c ASC,Market__c];
                
            }
        }
        catch(Exception E) 
        {
            system.debug('Exception occurred during execution of ProductTrends method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
        Object ProductTrendsObject=productTrendsProcessor();
        return ProductTrendsObject;
        
    }
    
    /* 
* @Method Name                    :  productTrendsProcessor
* @Description                    :  Utility method to form JSONs associated to Product trends report                                      
* @Return Type                    :  object
* @Param                          :  
*/    
    global static Object productTrendsProcessor()
        
    {   
        Map<Decimal, Set<Decimal>> YearAndMonthsMap = new Map<Decimal, Set<Decimal>>();
        Map<Decimal, Map<Decimal, List<MYBZ_Market_Share__c>>> YearAndMonthProductTrendMap = new Map<Decimal, Map<Decimal, List<MYBZ_Market_Share__c>>>();
        Set<Decimal> productTrendYear = new Set<Decimal>();
        Object ProductTrendsObject;
        Decimal EffientTrx;
        Decimal EffientDollars;
        Decimal EffientUnits;
        
        //To determine if Effient product is present in the current month
        integer EffientFlag = 0;
        try
        {
            if(!productTrendsList.isEmpty()){
                for(MYBZ_Market_Share__c productTrendObj : productTrendsList){
                    productTrendYear.add(productTrendObj.Year__c);
                }
            }
            if(!productTrendYear.isEmpty()){
                for(Decimal year : productTrendYear){
                    for(MYBZ_Market_Share__c productTrendObj : productTrendsList){
                        if(productTrendObj.Year__c == year){
                            if(!YearAndMonthsMap.containsKey(year)){
                                Set<Decimal> MonthsSet = new Set<Decimal>();
                                MonthsSet.add(productTrendObj.Month__c);
                                YearAndMonthsMap.put(year, MonthsSet);
                            }
                            else{
                                YearAndMonthsMap.get(year).add(productTrendObj.Month__c);
                            }
                        }
                    }
                }
            }
            if(!productTrendYear.isEmpty() && !YearAndMonthsMap.isEmpty()){
                for(Decimal year : productTrendYear){
                    
                    Map<Decimal, List<MYBZ_Market_Share__c>> MonthAndProductTrendMap = new Map<Decimal, List<MYBZ_Market_Share__c>>();
                    if(YearAndMonthsMap.containsKey(year)){
                        for(Decimal month : YearAndMonthsMap.get(year)){
                            List<MYBZ_Market_Share__c> productTrendMonthList = new List<MYBZ_Market_Share__c>();
                            for(MYBZ_Market_Share__c productTrendObj : productTrendsList){
                                if(productTrendObj.Month__c == month && productTrendObj.Year__c == year){
                                    productTrendMonthList.add(productTrendObj);
                                }
                            }
                            MonthAndProductTrendMap.put(month, productTrendMonthList);
                        }
                    }
                    YearAndMonthProductTrendMap.put(year, MonthAndProductTrendMap);
                }
            }
            
            if(!productTrendYear.isEmpty() && !YearAndMonthProductTrendMap.isEmpty()){
                generator = JSON.createGenerator(true);
                generator.writeStartArray();
                for(Decimal year : productTrendYear){
                    if(YearAndMonthProductTrendMap.containsKey(year)){
                        Map<Decimal, List<MYBZ_Market_Share__c>> TempMonthAndProductTrendMap = YearAndMonthProductTrendMap.get(year);
                        for(Decimal month : TempMonthAndProductTrendMap.keySet()){
                            EffientFlag=0;
                            generator.writeStartObject();
                            generator.writeNumberField(System.Label.MYBZ_month,month);
                            generator.writeNumberField(System.Label.MYBZ_Year,year);
                            if(TempMonthAndProductTrendMap.get(month) !=null){
                                generator.writeFieldName(System.Label.MYBZ_Products);
                                generator.writeStartArray();
                                for(MYBZ_Market_Share__c productTrendObj : TempMonthAndProductTrendMap.get(month)){
                                    
                                    if(!productTrendObj.Product__r.Name.Equals(System.Label.MYBZ_EFFIENT))
                                    {
                                        generator.writeStartObject();
                                        generator.writeStringField(System.Label.MYBZ_productName,productTrendObj.Product__r.Name);
                                        if(productTrendObj.TRx__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_trx,productTrendObj.TRx__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_trx);
                                        }
                                        if(productTrendObj.DDD_Dollars__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_dddDollars,productTrendObj.DDD_Dollars__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_dddDollars);
                                        }
                                        if(productTrendObj.DDD_Units__c!=null)
                                        {
                                            generator.writeNumberField(System.Label.MYBZ_dddUnits,productTrendObj.DDD_Units__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_dddUnits);
                                        }
                                        if(productTrendObj.Previous_Month_TRx__c!=null)
                                        {
                                            if(productTrendObj.Previous_Month_TRx__c!=0)
                                            {
                                                PercentageChangeTRx = ((productTrendObj.TRx__c - productTrendObj.Previous_Month_TRx__c)/productTrendObj.Previous_Month_TRx__c);
                                                PercentageChangeTRx = PercentageChangeTRx.SetScale(2,RoundingMode.CEILING);
                                            }
                                            else
                                            {
                                                PercentageChangeTRx=0;
                                            }
                                            generator.writeNumberField(System.Label.MYBZ_percentageChangeFromPreviousMonthTRx,PercentageChangeTRx); 
                                            
                                        }
                                        else
                                            generator.writeNullField(System.Label.MYBZ_percentageChangeFromPreviousMonthTRx);
                                        
                                        if(productTrendObj.Previous_DDD_Dollars__c!=null)
                                        {
                                            if(productTrendObj.Previous_DDD_Dollars__c!=0)
                                            {
                                                PercentageChangeDDDDollars = ((productTrendObj.DDD_Dollars__c - productTrendObj.Previous_DDD_Dollars__c)/productTrendObj.Previous_DDD_Dollars__c);
                                                PercentageChangeDDDDollars = PercentageChangeDDDDollars.SetScale(2,RoundingMode.CEILING);
                                            }
                                            else
                                            {
                                                PercentageChangeDDDDollars=0;
                                            }
                                            generator.writeNumberField(System.Label.MYBZ_percentageChangeFromPreviousMonthDDDDollars,PercentageChangeDDDDollars); 
                                            system.debug('Previous_DDD_Dollars__c'+productTrendObj.Previous_DDD_Dollars__c);
                                        }
                                        else
                                            generator.writeNullField(System.Label.MYBZ_percentageChangeFromPreviousMonthDDDDollars);
                                        
                                        if(productTrendObj.Previous_DDD_Units__c!=null)
                                        {
                                            if(productTrendObj.Previous_DDD_Units__c!=0)
                                            {
                                                PercentageChangeDDDUnits = ((productTrendObj.DDD_Units__c - productTrendObj.Previous_DDD_Units__c)/productTrendObj.Previous_DDD_Units__c);
                                                PercentageChangeDDDUnits = PercentageChangeDDDUnits.SetScale(2,RoundingMode.CEILING);
                                            }
                                            else
                                            {
                                                PercentageChangeDDDUnits=0;
                                            }
                                            generator.writeNumberField(System.Label.MYBZ_percentageChangeFromPreviousMonthDDDUnits,PercentageChangeDDDUnits);   
                                            system.debug('Previous_DDD_Dollars__c'+productTrendObj.Previous_DDD_Units__c);
                                        }
                                        else
                                            generator.writeNullField(System.Label.MYBZ_percentageChangeFromPreviousMonthDDDUnits); 
                                        
                                        generator.writeBooleanField(System.Label.MYBZ_lillyProduct,productTrendObj.lillyProduct__c);
                                        generator.writeEndObject();
                                    }
                                    else
                                    {
                                        if(EffientFlag==0){
                                            EffientFlag = 1;
                                        }   
                                        if(productTrendObj.TRx__c!=null)
                                        {
                                            EffientTrx=productTrendObj.TRx__c;
                                            if(productTrendObj.Previous_Month_TRx__c!=null)
                                            {
                                                if(productTrendObj.Previous_Month_TRx__c!=0)
                                                {
                                                    PercentageChangeTRx = ((productTrendObj.TRx__c - productTrendObj.Previous_Month_TRx__c)/productTrendObj.Previous_Month_TRx__c);
                                                    PercentageChangeTRx = PercentageChangeTRx.SetScale(2,RoundingMode.CEILING);
                                                }
                                                else
                                                {
                                                    PercentageChangeTRx=0;
                                                }
                                                
                                            }
                                            
                                        }
                                        if(productTrendObj.DDD_Dollars__c!=null)
                                        {
                                            EffientDollars=productTrendObj.DDD_Dollars__c;
                                            if(productTrendObj.Previous_DDD_Dollars__c!=0)
                                            {
                                                PercentageChangeDDDDollars = ((productTrendObj.DDD_Dollars__c - productTrendObj.Previous_DDD_Dollars__c)/productTrendObj.Previous_DDD_Dollars__c);
                                                PercentageChangeDDDDollars = PercentageChangeDDDDollars.SetScale(2,RoundingMode.CEILING);
                                            }
                                            else
                                            {
                                                PercentageChangeDDDDollars=0;
                                            }
                                        }
                                        if(productTrendObj.DDD_Units__c!=null)
                                        {
                                            EffientUnits=productTrendObj.DDD_Units__c;
                                            if(productTrendObj.Previous_DDD_Units__c!=0)
                                            {
                                                PercentageChangeDDDUnits = ((productTrendObj.DDD_Units__c - productTrendObj.Previous_DDD_Units__c)/productTrendObj.Previous_DDD_Units__c);
                                                PercentageChangeDDDUnits = PercentageChangeDDDUnits.SetScale(2,RoundingMode.CEILING);
                                            }
                                            else
                                            {
                                                PercentageChangeDDDUnits=0;
                                            }
                                        }   
                                    }
                                    
                                }
                                if(EffientFlag==1)
                                {
                                    generator.writeStartObject();
                                    generator.writeStringField(System.Label.MYBZ_productName,System.Label.MYBZ_EFFIENT);
                                    if(EffientTrx!=null){
                                        generator.writeNumberField(System.Label.MYBZ_trx,EffientTrx);
                                    }   
                                    else
                                    {
                                        generator.writeNullField(System.Label.MYBZ_trx);
                                    }
                                    if(EffientDollars!=null){
                                        generator.writeNumberField(System.Label.MYBZ_dddDollars,EffientDollars);
                                    }
                                    else
                                    {
                                        generator.writeNullField(System.Label.MYBZ_dddDollars);
                                    }
                                    if(EffientUnits!=null){
                                        generator.writeNumberField(System.Label.MYBZ_dddUnits,EffientUnits);
                                    }
                                    else
                                    {
                                        generator.writeNullField(System.Label.MYBZ_dddUnits);
                                    }
                                    if(PercentageChangeTRx!=null){
                                        generator.writeNumberField(System.Label.MYBZ_percentageChangeFromPreviousMonthTRx,PercentageChangeTRx);
                                    }
                                    else
                                    {
                                        generator.writeNullField(System.Label.MYBZ_percentageChangeFromPreviousMonthTRx); 
                                    }
                                    if(PercentageChangeDDDDollars!=null){
                                        generator.writeNumberField(System.Label.MYBZ_percentageChangeFromPreviousMonthDDDDollars,PercentageChangeDDDDollars); 
                                    }
                                    else
                                    {
                                        generator.writeNullField(System.Label.MYBZ_percentageChangeFromPreviousMonthDDDDollars);
                                    }
                                    if(PercentageChangeDDDUnits!=null){
                                        generator.writeNumberField(System.Label.MYBZ_percentageChangeFromPreviousMonthDDDUnits,PercentageChangeDDDUnits);
                                    }
                                    else
                                    {    
                                        generator.writeNullField(System.Label.MYBZ_percentageChangeFromPreviousMonthDDDUnits);
                                    }
                                    generator.writeBooleanField(System.Label.MYBZ_lillyProduct,true);
                                    generator.writeEndObject();
                                    EffientFlag=0;
                                }
                                generator.writeEndArray();
                            }
                            generator.writeEndObject();
                        }
                    }
                }
                generator.writeEndArray();
                JsonString = generator.getAsString();
                System.debug('--ProductTrends'+JsonString);
                ProductTrendsObject = Json.deserializeUntyped(JsonString);
            }
        }
        
        catch(Exception E) 
        {
            system.debug('Exception occurred during execution of ProductTrends method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
        
        return ProductTrendsObject;
    }
    
    /* 
* @Method Name                    :  regionRollup
* @Description                    :  JavaScript remoting to allow Region Rollup records to be retrieved from Salesforce in the form of a JSON object to show Region Rollup Report.                                        
* @Return Type                    :  object
* @Param                          :    

*/    
    @RemoteAction 
    global static Object regionRollup()
    {
        try
        {
            //Call fetch user function so that Role and Global id value is available in this method.
            fetchUserInfo();
            
            //Checking if the division record exist. There will be only one Division record.
            MYBZ_IHS_Division__c divisionObj = [SELECT Name FROM MYBZ_IHS_Division__c LIMIT 1];
            
            //Set of unique Region id's.
            Set<Id> regionIds = new Set<Id>();
            
            //Set of unique district id's.
            Set<Id> districtIds = new Set<Id>();
            
            //Getting the first Region to fetch the metric dates as all the regions have same dates.
            MYBZ_Region_Rollup__c firstRegionNameObj;
            
            //Initializing the date range.
            List<String> rangeData = new List<String>{'oneMonthData','threeMonthData','sixMonthData'};
            
            //Initializing the metric dates.
                List<String> metricDates = new List<String>{'opexStartDates','netProfitStartDates','grossMarginsStartDates','trxStartDates','nrxStartDates','dddStartDates'};
            
            List <MYBZ_Region_Rollup__c> regionList = new List <MYBZ_Region_Rollup__c>();
            List <MYBZ_Region_Rollup__c> districtList = new List <MYBZ_Region_Rollup__c>();
            List <MYBZ_Region_Rollup__c> territoryList = new List <MYBZ_Region_Rollup__c>();
            Map<String,Map<String,MYBZ_Region_Rollup__c>> mapRegionNameAndRegion=new Map<String,Map<String,MYBZ_Region_Rollup__c>>();
            Map<String,Set<String>> mapRegionNameAndDistrictName=new Map<String,Set<String>>();
            Map<String,Map<String,MYBZ_Region_Rollup__c>> mapDistrictNameAndDistrict=new Map<String,Map<String,MYBZ_Region_Rollup__c>>();
            Map<String,Set<String>> mapDistrictNameAndTerritoryName=new Map<String,Set<String>>();
            Map<String, Map<String,MYBZ_Region_Rollup__c>> mapTerritoryNameAndTerritory = new  Map<String, Map<String,MYBZ_Region_Rollup__c>>();
            
            //Fetching all the Region Rollup data at once and then segregating it in form of Region, district, Territory. 
            for(MYBZ_Region_Rollup__c regRoll : [SELECT Region__r.Name, District__r.Name, Territory__r.Name, Gross_Margin_1M__c, Gross_Margin_3M__c, Gross_Margin_6M__c, Gross_Margin_Start_Date_1M__c, Gross_Margin_Start_Date_3M__c, Gross_Margin_Start_Date_6M__c, Net_Profit_1M__c, Net_Profit_3M__c, Net_Profit_6M__c, Net_Profit_Start_Date_1M__c, Net_Profit_Start_Date_3M__c, Net_Profit_Start_Date_6M__c, NRx_1M__c, NRx_3M__c, NRx_6M__c, NRx_Start_Date_1M__c, NRx_Start_Date_3M__c, NRx_Start_Date_6M__c, OPEX_1M__c, OPEX_3M__c, OPEX_6M__c, OPEX_Start_Date_1M__c, OPEX_Start_Date_3M__c, OPEX_Start_Date_6M__c, TRx_1M__c, TRx_3M__c, TRx_6M__c, TRx_Start_Date_1M__c, TRx_Start_Date_3M__c, TRx_Start_Date_6M__c, DDD_Dollars_1M__c, DDD_Dollars_3M__c, DDD_Dollars_6M__c, DDD_Dollars_Start_Date_1M__c, DDD_Dollars_Start_Date_3M__c, DDD_Dollars_Start_Date_6M__c, Global_Id__c, Region__r.Parent__c, Product__r.Name, Alignment_Level__c FROM MYBZ_Region_Rollup__c WHERE Region__r.Parent__c =: divisionObj.id AND Product__c!=null]){
                if(regRoll.Alignment_Level__c == System.Label.MYBZ_Region){
                    regionList.add(regRoll);
                }
                if(regRoll.Alignment_Level__c == System.Label.MYBZ_District){
                    districtList.add(regRoll);
                }
                if(regRoll.Alignment_Level__c == System.Label.MYBZ_Territory){
                    territoryList.add(regRoll);
                }
            }
            if(!regionList.isEmpty()){
                for(MYBZ_Region_Rollup__c regionObj : regionList)
                {
                    if(!mapRegionNameAndRegion.containsKey(regionObj.Region__r.Name))
                    {
                        Map<String,MYBZ_Region_Rollup__c> tempRegionRollupMap = new Map<String,MYBZ_Region_Rollup__c>();
                        tempRegionRollupMap.put(regionObj.Product__r.Name,regionObj);
                        mapRegionNameAndRegion.put(regionObj.Region__r.Name,tempRegionRollupMap);
                    }
                    else 
                    {
                        if(!mapRegionNameAndRegion.get(regionObj.Region__r.Name).containsKey(regionObj.Product__r.Name)){
                            mapRegionNameAndRegion.get(regionObj.Region__r.Name).put(regionObj.Product__r.Name,regionObj);
                        }
                        
                    }
                }
            }
            if(!districtList.isEmpty()){
                for(MYBZ_Region_Rollup__c districtObj : districtList)
                {
                    if(!mapRegionNameAndDistrictName.containsKey(districtObj.Region__r.Name))
                    {
                        Set<String> tempDistrictName=new Set<String>();
                        tempDistrictName.add(districtObj.District__r.Name);
                        mapRegionNameAndDistrictName.put(districtObj.Region__r.Name,tempDistrictName);
                    }
                    else 
                    {
                        mapRegionNameAndDistrictName.get(districtObj.Region__r.Name).add(districtObj.District__r.Name);
                    }
                    if(!mapDistrictNameAndDistrict.containsKey(districtObj.District__r.Name))
                    {
                        Map<String,MYBZ_Region_Rollup__c> tempDistrictMap = new Map<String,MYBZ_Region_Rollup__c>();
                        tempDistrictMap.put(districtObj.Product__r.Name,districtObj);
                        mapDistrictNameAndDistrict.put(districtObj.District__r.Name,tempDistrictMap);
                        
                    }
                    else 
                    {
                        if(!mapDistrictNameAndDistrict.get(districtObj.District__r.Name).containsKey(districtObj.Product__r.Name)){
                            mapDistrictNameAndDistrict.get(districtObj.District__r.Name).put(districtObj.Product__r.Name,districtObj);
                        }
                        
                    }
                }
            }
            
            
            if(!territoryList.isEmpty()){
                
                for(MYBZ_Region_Rollup__c territoryObj : territoryList){
                    
                    if(!mapDistrictNameAndTerritoryName.containsKey(territoryObj.District__r.Name))
                    {
                        Set<String> tempTerrName=new Set<String>();
                        tempTerrName.add(territoryObj.Territory__r.Name);
                        mapDistrictNameAndTerritoryName.put(territoryObj.District__r.Name,tempTerrName);
                    }
                    else
                    {
                        mapDistrictNameAndTerritoryName.get(territoryObj.District__r.Name).add(territoryObj.Territory__r.Name);
                    }
                    if(!mapTerritoryNameAndTerritory.containsKey(territoryObj.Territory__r.Name))
                    {
                        Map<String,MYBZ_Region_Rollup__c> tempTerrMap = new Map<String,MYBZ_Region_Rollup__c>();
                        tempTerrMap.put(territoryObj.Product__r.Name,territoryObj);
                        mapTerritoryNameAndTerritory.put(territoryObj.Territory__r.Name,tempTerrMap);
                    }
                    else 
                    {
                        if(!mapTerritoryNameAndTerritory.get(territoryObj.Territory__r.Name).containsKey(territoryObj.Product__r.Name)){
                            mapTerritoryNameAndTerritory.get(territoryObj.Territory__r.Name).put(territoryObj.Product__r.Name,territoryObj);
                        }
                    }
                }
            }
            
            if(!regionList.isEmpty()){
                for(MYBZ_Region_Rollup__c regionObj : regionList){
                    if(regionObj.Product__r.Name == System.Label.MYBZ_EFFIENT){                    
                        firstRegionNameObj = regionObj;
                        break;
                    }
                }
                //Returns a new JSON generator.
                generator = JSON.createGenerator(true);
                
                //Writes the starting marker of a JSON Object.
                generator.writeStartObject();  
                
                //Start of writing the JSON fields.
                generator.writeStringField(System.Label.MYBZ_Name,divisionObj.Name);
    
                //Start of writing the date fields of all the metrics.
                for(String str : metricDates){
                    if(firstRegionNameObj !=null){
                        generator.writeFieldName(str);
                        generator.writeStartObject();
                        if(str == 'opexStartDates'){
                            if(firstRegionNameObj.OPEX_Start_Date_1M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_oneMonthDataStartDate,firstRegionNameObj.OPEX_Start_Date_1M__c);
                            }
                            if(firstRegionNameObj.OPEX_Start_Date_3M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_threeMonthDataStartDate,firstRegionNameObj.OPEX_Start_Date_3M__c);
                            }
                            if(firstRegionNameObj.OPEX_Start_Date_6M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_sixMonthDataStartDate,firstRegionNameObj.OPEX_Start_Date_6M__c);
                            }
                        }
                        else if(str == 'netProfitStartDates'){
                            if(firstRegionNameObj.Net_Profit_Start_Date_1M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_oneMonthDataStartDate,firstRegionNameObj.Net_Profit_Start_Date_1M__c);
                            }
                            if(firstRegionNameObj.Net_Profit_Start_Date_3M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_threeMonthDataStartDate,firstRegionNameObj.Net_Profit_Start_Date_3M__c);
                            }
                            if(firstRegionNameObj.Net_Profit_Start_Date_6M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_sixMonthDataStartDate,firstRegionNameObj.Net_Profit_Start_Date_6M__c);
                            }
                        }
                        else if(str == 'grossMarginsStartDates'){
                            if(firstRegionNameObj.Gross_Margin_Start_Date_1M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_oneMonthDataStartDate,firstRegionNameObj.Gross_Margin_Start_Date_1M__c);
                            }
                            if(firstRegionNameObj.Gross_Margin_Start_Date_3M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_threeMonthDataStartDate,firstRegionNameObj.Gross_Margin_Start_Date_3M__c);
                            }
                            if(firstRegionNameObj.Gross_Margin_Start_Date_6M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_sixMonthDataStartDate,firstRegionNameObj.Gross_Margin_Start_Date_6M__c);
                            }
                        }
                        else if(str == 'trxStartDates'){
                            if(firstRegionNameObj.TRx_Start_Date_1M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_oneMonthDataStartDate,firstRegionNameObj.TRx_Start_Date_1M__c);
                            }
                            if(firstRegionNameObj.TRx_Start_Date_3M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_threeMonthDataStartDate,firstRegionNameObj.TRx_Start_Date_3M__c);
                            }
                            if(firstRegionNameObj.TRx_Start_Date_6M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_sixMonthDataStartDate,firstRegionNameObj.TRx_Start_Date_6M__c);
                            }
                        }
                        else if(str == 'nrxStartDates'){
                            if(firstRegionNameObj.NRx_Start_Date_1M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_oneMonthDataStartDate,firstRegionNameObj.NRx_Start_Date_1M__c);
                            }
                            if(firstRegionNameObj.NRx_Start_Date_3M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_threeMonthDataStartDate,firstRegionNameObj.NRx_Start_Date_3M__c);
                            }
                            if(firstRegionNameObj.NRx_Start_Date_6M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_sixMonthDataStartDate,firstRegionNameObj.NRx_Start_Date_6M__c);
                            }
                        }
                        else if(str == 'dddStartDates'){
                            if(firstRegionNameObj.DDD_Dollars_Start_Date_1M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_oneMonthDataStartDate,firstRegionNameObj.DDD_Dollars_Start_Date_1M__c);
                            }
                            if(firstRegionNameObj.DDD_Dollars_Start_Date_3M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_threeMonthDataStartDate,firstRegionNameObj.DDD_Dollars_Start_Date_3M__c);
                            }
                            if(firstRegionNameObj.DDD_Dollars_Start_Date_6M__c != null){
                                generator.writeDateTimeField(System.Label.MYBZ_sixMonthDataStartDate,firstRegionNameObj.DDD_Dollars_Start_Date_6M__c);
                            }
                        }
                        
                        //Writes the ending marker of a JSON Object.
                        generator.writeEndObject();
                    }
                }
                if(!mapRegionNameAndRegion.isEmpty()){
                    generator.writeFieldName(System.Label.MYBZ_children);
                    generator.writeStartArray();
                    for(String regionName : mapRegionNameAndRegion.keySet())
                    {
                        generator.writeStartObject(); 
                        generator.writeStringField(System.Label.MYBZ_Name,regionName);
                        if(!mapRegionNameAndRegion.get(regionName).isEmpty())
                        {
                            Map<String,MYBZ_Region_Rollup__c> regionsMap = mapRegionNameAndRegion.get(regionName);
                            for(String str : rangeData){
                                generator.writeFieldName(str);
                                generator.writeStartArray();
                                
                                //Start of writing fields of region as per the range.
                                for(String eachProduct : regionsMap.keySet()){
                                    MYBZ_Region_Rollup__c tempRegionObj = regionsMap.get(eachProduct);
                                    if(str == 'oneMonthData'){
                                        generator.writeStartObject();
                                        if(tempRegionObj.Product__c!=null){
                                            generator.writeStringField(System.Label.MYBZ_Name,tempRegionObj.Product__r.Name);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_Name);
                                        }
                                        if(tempRegionObj.TRx_1M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_trxValue,tempRegionObj.TRx_1M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_trxValue);
                                        }   
                                        if(tempRegionObj.NRx_1M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_nrxValue,tempRegionObj.NRx_1M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_nrxValue);
                                        }   
                                        if(tempRegionObj.OPEX_1M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_opex,tempRegionObj.OPEX_1M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_opex);
                                        }   
                                        if(tempRegionObj.Gross_Margin_1M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_grossMargins,tempRegionObj.Gross_Margin_1M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_grossMargins);
                                        }
                                        if(tempRegionObj.Net_Profit_1M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_netProfit,tempRegionObj.Net_Profit_1M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_netProfit);
                                        }
                                        if(tempRegionObj.DDD_Dollars_1M__c !=null){
                                            generator.writeNumberField(System.Label.MYBZ_dddDollars,tempRegionObj.DDD_Dollars_1M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_dddDollars);
                                        }
                                        generator.writeEndObject();
                                    }
                                    if(str == 'threeMonthData'){
                                        generator.writeStartObject();
                                        if(tempRegionObj.Product__c!=null){
                                            generator.writeStringField(System.Label.MYBZ_Name,tempRegionObj.Product__r.Name);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_Name);
                                        }
                                        if(tempRegionObj.TRx_3M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_trxValue,tempRegionObj.TRx_3M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_trxValue);
                                        }   
                                        if(tempRegionObj.NRx_3M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_nrxValue,tempRegionObj.NRx_3M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_nrxValue);
                                        }   
                                        if(tempRegionObj.OPEX_3M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_opex,tempRegionObj.OPEX_3M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_opex);
                                        }   
                                        if(tempRegionObj.Gross_Margin_3M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_grossMargins,tempRegionObj.Gross_Margin_3M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_grossMargins);
                                        }
                                        if(tempRegionObj.Net_Profit_3M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_netProfit,tempRegionObj.Net_Profit_3M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_netProfit);
                                        }
                                        if(tempRegionObj.DDD_Dollars_3M__c !=null){
                                            generator.writeNumberField(System.Label.MYBZ_dddDollars,tempRegionObj.DDD_Dollars_3M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_dddDollars);
                                        }       
                                        generator.writeEndObject();
                                    }
                                    if(str == 'sixMonthData'){
                                        generator.writeStartObject();
                                        if(tempRegionObj.Product__c!=null){
                                            generator.writeStringField(System.Label.MYBZ_Name,tempRegionObj.Product__r.Name);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_Name);
                                        }
                                        if(tempRegionObj.TRx_6M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_trxValue,tempRegionObj.TRx_6M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_trxValue);
                                        }   
                                        if(tempRegionObj.NRx_6M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_nrxValue,tempRegionObj.NRx_6M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_nrxValue);
                                        }   
                                        if(tempRegionObj.OPEX_6M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_opex,tempRegionObj.OPEX_6M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_opex);
                                        }   
                                        if(tempRegionObj.Gross_Margin_6M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_grossMargins,tempRegionObj.Gross_Margin_6M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_grossMargins);
                                        }
                                        if(tempRegionObj.Net_Profit_6M__c!=null){
                                            generator.writeNumberField(System.Label.MYBZ_netProfit,tempRegionObj.Net_Profit_6M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_netProfit);
                                        }
                                        if(tempRegionObj.DDD_Dollars_6M__c !=null){
                                            generator.writeNumberField(System.Label.MYBZ_dddDollars,tempRegionObj.DDD_Dollars_6M__c);
                                        }
                                        else
                                        {
                                            generator.writeNullField(System.Label.MYBZ_dddDollars);
                                        }
                                        generator.writeEndObject();
                                    }
                                }
                                generator.writeEndArray();
                            }
                        }
                        
                        if(!mapRegionNameAndDistrictName.get(regionName).isEmpty()){
                            generator.writeFieldName(System.Label.MYBZ_children);
                            generator.writeStartArray();
                            
                            //Start of writing fields of district as per the range.
                            for(String distName : mapRegionNameAndDistrictName.get(regionName))
                            {
                                generator.writeStartObject(); 
                                generator.writeStringField(System.Label.MYBZ_Name,distName);                           
                                if(!mapDistrictNameAndDistrict.get(distName).isEmpty())
                                {
                                    Map<String,MYBZ_Region_Rollup__c> distMap = mapDistrictNameAndDistrict.get(distName);
                                    for(String str : rangeData){
                                        generator.writeFieldName(str);
                                        generator.writeStartArray();
                                        for(String eachProduct : distMap.keySet()){
                                            MYBZ_Region_Rollup__c tempdistObj = distMap.get(eachProduct);
                                            if(str == 'oneMonthData'){
                                                generator.writeStartObject();
                                                
                                                if(tempdistObj.Product__c!=null){
                                                    generator.writeStringField(System.Label.MYBZ_Name,tempdistObj.Product__r.Name);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_Name);
                                                }
                                                if(tempdistObj.TRx_1M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_trxValue,tempdistObj.TRx_1M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_trxValue);
                                                }   
                                                if(tempdistObj.NRx_1M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_nrxValue,tempdistObj.NRx_1M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_nrxValue);
                                                }   
                                                if(tempdistObj.OPEX_1M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_opex,tempdistObj.OPEX_1M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_opex);
                                                }           
                                                if(tempdistObj.Gross_Margin_1M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_grossMargins,tempdistObj.Gross_Margin_1M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_grossMargins);
                                                }
                                                if(tempdistObj.Net_Profit_1M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_netProfit,tempdistObj.Net_Profit_1M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_netProfit);
                                                }
                                                if(tempdistObj.DDD_Dollars_1M__c !=null){
                                                    generator.writeNumberField(System.Label.MYBZ_dddDollars,tempdistObj.DDD_Dollars_1M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_dddDollars);
                                                }
                                                generator.writeEndObject();
                                            }
                                            if(str == 'threeMonthData'){
                                                generator.writeStartObject();
                                                if(tempdistObj.Product__c!=null){
                                                    generator.writeStringField(System.Label.MYBZ_Name,tempdistObj.Product__r.Name);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_Name);
                                                }
                                                if(tempdistObj.TRx_3M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_trxValue,tempdistObj.TRx_3M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_trxValue);
                                                }   
                                                if(tempdistObj.NRx_3M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_nrxValue,tempdistObj.NRx_3M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_nrxValue);
                                                }   
                                                if(tempdistObj.OPEX_3M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_opex,tempdistObj.OPEX_3M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_opex);
                                                }   
                                                if(tempdistObj.Gross_Margin_3M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_grossMargins,tempdistObj.Gross_Margin_3M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_grossMargins);
                                                }
                                                if(tempdistObj.Net_Profit_3M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_netProfit,tempdistObj.Net_Profit_3M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_netProfit);
                                                }
                                                if(tempdistObj.DDD_Dollars_3M__c !=null){
                                                    generator.writeNumberField(System.Label.MYBZ_dddDollars,tempdistObj.DDD_Dollars_3M__c);
                                                }
                                                else
                                                { 
                                                    generator.writeNullField(System.Label.MYBZ_dddDollars);
                                                }
                                                generator.writeEndObject();
                                            }
                                            if(str == 'sixMonthData'){
                                                generator.writeStartObject();
                                                if(tempdistObj.Product__c!=null){
                                                    generator.writeStringField(System.Label.MYBZ_Name,tempdistObj.Product__r.Name);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_Name);
                                                }
                                                if(tempdistObj.TRx_6M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_trxValue,tempdistObj.TRx_6M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_trxValue);
                                                }   
                                                if(tempdistObj.NRx_6M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_nrxValue,tempdistObj.NRx_6M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_nrxValue);
                                                }   
                                                if(tempdistObj.OPEX_6M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_opex,tempdistObj.OPEX_6M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_opex);
                                                }   
                                                if(tempdistObj.Gross_Margin_6M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_grossMargins,tempdistObj.Gross_Margin_6M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_grossMargins);
                                                }
                                                if(tempdistObj.Net_Profit_6M__c!=null){
                                                    generator.writeNumberField(System.Label.MYBZ_netProfit,tempdistObj.Net_Profit_6M__c);
                                                }
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_netProfit);
                                                }
                                                if(tempdistObj.DDD_Dollars_6M__c !=null){
                                                    generator.writeNumberField(System.Label.MYBZ_dddDollars,tempdistObj.DDD_Dollars_6M__c);
                                                }   
                                                else
                                                {
                                                    generator.writeNullField(System.Label.MYBZ_dddDollars);
                                                }
                                                generator.writeEndObject();
                                            }
                                        }
                                        generator.writeEndArray();
                                    }
                                }
                                if(!mapDistrictNameAndTerritoryName.get(distName).isEmpty()){
                                    generator.writeFieldName(System.Label.MYBZ_children);
                                    generator.writeStartArray();
                                    for(String terrName : mapDistrictNameAndTerritoryName.get(distName))
                                    {
                                        generator.writeStartObject(); 
                                        
                                         //Start of writing fields of territory as per the range.
                                        generator.writeStringField(System.Label.MYBZ_Name,terrName);
                                        
                                        if(!mapTerritoryNameAndTerritory.get(terrName).isEmpty())
                                        {
                                            Map<String,MYBZ_Region_Rollup__c> terrMap = mapTerritoryNameAndTerritory.get(terrName);
                                            for(String str : rangeData){
                                                generator.writeFieldName(str);
                                                generator.writeStartArray();
                                                for(String eachProduct : terrMap.keySet()){
                                                    MYBZ_Region_Rollup__c tempTerrtObj = terrMap.get(eachProduct);
                                                    if(str == 'oneMonthData'){
                                                        generator.writeStartObject();
                                                        if(tempTerrtObj.Product__c!=null){
                                                            generator.writeStringField(System.Label.MYBZ_Name,tempTerrtObj.Product__r.Name);
                                                        }
                                                        else
                                                        {
                                                            generator.writeNullField(System.Label.MYBZ_Name);
                                                        }
                                                        if(tempTerrtObj.TRx_1M__c!=null){
                                                            generator.writeNumberField(System.Label.MYBZ_trxValue,tempTerrtObj.TRx_1M__c);
                                                        }
                                                        else
                                                        {
                                                            generator.writeNullField(System.Label.MYBZ_trxValue);
                                                        }   
                                                        if(tempTerrtObj.NRx_1M__c!=null){
                                                            generator.writeNumberField(System.Label.MYBZ_nrxValue,tempTerrtObj.NRx_1M__c);
                                                        }
                                                        else
                                                        {
                                                            generator.writeNullField(System.Label.MYBZ_nrxValue);
                                                        }
                                                        if(tempTerrtObj.DDD_Dollars_1M__c !=null){
                                                            generator.writeNumberField(System.Label.MYBZ_dddDollars,tempTerrtObj.DDD_Dollars_1M__c);
                                                        }
                                                        else
                                                        {
                                                            generator.writeNullField(System.Label.MYBZ_dddDollars);
                                                        }
                                                        generator.writeEndObject();
                                                    }
                                                    if(str == 'threeMonthData'){
                                                        generator.writeStartObject();
                                                        if(tempTerrtObj.Product__c!=null){
                                                            generator.writeStringField(System.Label.MYBZ_Name,tempTerrtObj.Product__r.Name);
                                                        }
                                                        else
                                                        {
                                                            generator.writeNullField(System.Label.MYBZ_Name);
                                                        }
                                                        if(tempTerrtObj.TRx_3M__c!=null){
                                                            generator.writeNumberField(System.Label.MYBZ_trxValue,tempTerrtObj.TRx_3M__c);
                                                        }
                                                        else
                                                        {
                                                            generator.writeNullField(System.Label.MYBZ_trxValue);
                                                        }   
                                                        if(tempTerrtObj.NRx_3M__c!=null){
                                                            generator.writeNumberField(System.Label.MYBZ_nrxValue,tempTerrtObj.NRx_3M__c);
                                                        }
                                                        else
                                                        {
                                                            generator.writeNullField(System.Label.MYBZ_nrxValue);
                                                        }
                                                        if(tempTerrtObj.DDD_Dollars_3M__c !=null){
                                                            generator.writeNumberField(System.Label.MYBZ_dddDollars,tempTerrtObj.DDD_Dollars_3M__c);
                                                        }
                                                        else
                                                        {
                                                            generator.writeNullField(System.Label.MYBZ_dddDollars);
                                                        }
                                                        generator.writeEndObject();
                                                    }
                                                    if(str == 'sixMonthData'){
                                                        generator.writeStartObject();
                                                        if(tempTerrtObj.Product__c!=null){
                                                            generator.writeStringField(System.Label.MYBZ_Name,tempTerrtObj.Product__r.Name);
                                                        }
                                                        else
                                                        {
                                                            generator.writeNullField(System.Label.MYBZ_Name);
                                                        }
                                                        if(tempTerrtObj.TRx_6M__c!=null){
                                                            generator.writeNumberField(System.Label.MYBZ_trxValue,tempTerrtObj.TRx_6M__c);
                                                        }
                                                        else
                                                        {
                                                            generator.writeNullField(System.Label.MYBZ_trxValue);
                                                        }   
                                                        if(tempTerrtObj.NRx_6M__c!=null){
                                                            generator.writeNumberField(System.Label.MYBZ_nrxValue,tempTerrtObj.NRx_6M__c);
                                                        }
                                                        else
                                                        {
                                                            generator.writeNullField(System.Label.MYBZ_nrxValue);
                                                        }
                                                        if(tempTerrtObj.DDD_Dollars_6M__c !=null){
                                                            generator.writeNumberField(System.Label.MYBZ_dddDollars,tempTerrtObj.DDD_Dollars_6M__c);
                                                        }
                                                        else
                                                        {   
                                                            generator.writeNullField(System.Label.MYBZ_dddDollars);
                                                        }
                                                        generator.writeEndObject();
                                                    }
                                                }
                                                generator.writeEndArray();
                                            }
                                        }
                                        generator.writeEndObject(); 
                                    }
                                    generator.writeEndArray();
                                }
                                generator.writeEndObject();
                            }
                            generator.writeEndArray();
                        }
                        generator.writeEndObject();
                    }
                    
                    //Writes the ending marker of a JSON Array.
                    generator.writeEndArray();
                }
                
                //Writes the ending marker of a JSON Object.
                generator.writeEndObject();
            }
            JsonString = generator.getAsString();
            System.debug('--RegionRollup1'+JsonString );
            Object RegionRollupObject = Json.deserializeUntyped(JsonString);
            return RegionRollupObject;
        }
        catch(Exception E) 
        {
            system.debug('Exception occurred during execution of RegionRollup1 method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
    }
    
    /* 
* @Method Name                    :  trendsPrescriberUsingPicker
* @Description                    :  JavaScript remoting to allow top five prescribers for each month associated to a certain product to be  
retrieved from Salesforce in the form of a JSON object in the presence of a territory picker. 
* @Return Type                    :  object
* @Param                          :  Region - The region associated to the territory selected, District - The district associated to the territory selected
Territory - The territory selected via a territory picker.   

*/
    
    @RemoteAction 
    global static Object trendsPrescriberUsingPicker(String region, String district, String territory)
    {
        try
        {
            fetchUserInfo();
            if((Role == System.Label.MYBZ_MajorMarketManager || (Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager) || Role == System.Label.MYBZ_SuperUser) && district !=null && district !=''){
                TrendsDetailsList.clear();
                TrendsDetailsList = [Select Name,Month__c,Year__c,IHS_Product__c,Range__c,IHS_Product__r.Name,TRx_Units__c,Global_ID__c,HCP_First_Name__c,HCP_Last_Name__c from MYBZ_Product_Trend_Detail__c where District__r.Name =:district AND Territory__c = null order by Year__c,Month__c asc, IHS_Product__r.Name desc, TRx_Units__c desc];
            }
            if((Role == System.Label.MYBZ_MajorMarketManager || Role == System.Label.MYBZ_SuperUser) && region !=null && region !='' && (district ==null || district =='')){
                TrendsDetailsList.clear();
                TrendsDetailsList = [Select Name,Month__c,Year__c,IHS_Product__c,Range__c,IHS_Product__r.Name,TRx_Units__c,Global_ID__c,HCP_First_Name__c,HCP_Last_Name__c from MYBZ_Product_Trend_Detail__c where Area__r.Name =:region AND District__c = null order by Year__c,Month__c asc, IHS_Product__r.Name desc, TRx_Units__c desc];
            }
            if((Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager || Role == System.Label.MYBZ_SuperUser) && territory !=null && territory !=''){
                TrendsDetailsList.clear();
                TrendsDetailsList = [Select Name,Month__c,Year__c,IHS_Product__c,Range__c,IHS_Product__r.Name,TRx_Units__c,Global_ID__c,HCP_First_Name__c,HCP_Last_Name__c from MYBZ_Product_Trend_Detail__c where territory__r.Name =:territory order by Year__c,Month__c asc, IHS_Product__r.Name desc, TRx_Units__c desc];
            }
        }
        catch(Exception E) 
        {
            system.debug('Exception occurred during execution of RegionRollup1 method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
        
        Object trendsPrescriberObject=trendsPrescriberProcessor();
        System.debug('TrendsPrescriberObject--'+TrendsPrescriberObject);
        return trendsPrescriberObject;
    }
    
    /* 
* @Method Name                    :  trendsPrescriber
* @Description                    :  JavaScript remoting to allow top five prescribers for each month associated to a certain product to be  
retrieved from Salesforce in the form of a JSON object in the absence of a territory picker. 
* @Return Type                    :  object
* @Param                          :  

*/
    @RemoteAction 
    global static Object trendsPrescriber()
    {
        try
        {
            fetchUserInfo();
            if(Role == System.Label.MYBZ_SalesRepresentative || (Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager) || Role == System.Label.MYBZ_MajorMarketManager){
                TrendsDetailsList.clear();
                //List of all trend-details for a particular user
                TrendsDetailsList = [Select Name,Month__c,Year__c,IHS_Product__c,Range__c,IHS_Product__r.Name,TRx_Units__c,Global_ID__c,HCP_First_Name__c,HCP_Last_Name__c from MYBZ_Product_Trend_Detail__c where Global_ID__c=:GlobalId order by Year__c,Month__c asc, IHS_Product__r.Name desc, TRx_Units__c desc];
            }
            if(Role == System.Label.MYBZ_SuperUser){
                TrendsDetailsList.clear();
                
                MYBZ_Region__c reg=[Select id from MYBZ_Region__c where Name =: System.Label.MYBZ_defaultRegion ];
                
                TrendsDetailsList = [Select Name,Month__c,Year__c,IHS_Product__c,Range__c,IHS_Product__r.Name,TRx_Units__c,Global_ID__c,HCP_First_Name__c,HCP_Last_Name__c from MYBZ_Product_Trend_Detail__c where Area__c =:reg.Id and district__c=null order by Year__c,Month__c asc, IHS_Product__r.Name desc, TRx_Units__c desc];
            }
        }
        catch(Exception E) 
        {
            system.debug('Exception occurred during execution of RegionRollup1 method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
        
        Object trendsPrescriberObject=trendsPrescriberProcessor();
        System.debug('TrendsPrescriberObject--'+trendsPrescriberObject);
        return trendsPrescriberObject;
    }
    
    /* 
* @Method Name                    :  trendsPrescriberProcessor
* @Description                    :  Utility method for creating JSONs associated with TrendsPrescriber Report
* @Return Type                    :  object
* @Param                          :  

*/    
    global static Object trendsPrescriberProcessor()
    {
        try
        {
            if(TrendsDetailsList.isempty())
            {
                return null;
            }
            
            //Returns a new JSON Generator
            generator = JSON.createGenerator(true);
            generator.writeStartArray();  
            
            //Initializing variables
            String Years='';
            String Months;
            String Products='';
            Integer productprescribercount;
            Integer firstiteration=1;
            Integer prescriberflag=1;
            Integer firstproductIteration=1;
            //Looping over Trend-Details
            if(TrendsDetailsList != null && TrendsDetailsList.size() > 0){
                for(MYBZ_Product_Trend_Detail__c trenddetails : TrendsDetailsList)
                {
                    if(trenddetails.Year__c==null||trenddetails.Month__c==null){
                        continue;
                    }   
                    if(trenddetails.Year__c!=null)
                    {
                        if(!Years.equals(String.Valueof(trenddetails.Year__c)))
                        {
                            Years=String.Valueof(trenddetails.Year__c);
                            Months = '';
                        }
                    }
                    if(trenddetails.Month__c!=null)
                    {
                        if(!Months.equals(String.Valueof(trenddetails.Month__c)))
                        {
                            if(firstiteration==1)
                            {
                                generator.writeStartObject();
                                firstiteration=0;
                            }
                            else
                            {
                                
                                if(productprescribercount!=6)
                                {
                                    generator.writeEndArray();
                                    generator.writeEndObject();
                                    productprescribercount=1;
                                    prescriberflag=0;
                                }
                                generator.writeEndArray();
                                generator.writeEndObject();
                                generator.writeStartObject();
                            }
                            Months=String.Valueof(trenddetails.Month__c);
                            Products='';
                            
                            if(trenddetails.Month__c!=null){
                                generator.writeNumberField(System.Label.MYBZ_month,trenddetails.Month__c);
                            }
                            else
                            {
                                generator.writeNullField(System.Label.MYBZ_month);
                            }
                            if(trenddetails.Year__c!=null){
                                generator.writeNumberField(System.Label.MYBZ_Year,trenddetails.Year__c);
                            }
                            else
                            {
                                generator.writeNullField(System.Label.MYBZ_Year);
                            }
                            generator.writeFieldName(System.Label.MYBZ_Products);
                            generator.writeStartArray();      
                        }
                    } 
                    
                    //Determines if the same product has been encountered
                    if(trenddetails.IHS_Product__r.Name!=null)
                    {
                        if(!Products.equals(trenddetails.IHS_Product__r.Name))
                        {
                            
                            //Check to ensure only top five prescribers are taken into consideration while generating the JSON
                            if(productprescribercount!=6&&(prescriberflag==1)&&(firstproductIteration!=1))
                            {
                                generator.writeEndArray();
                                generator.writeEndObject();                                   
                            }
                            firstproductIteration=0;    
                            Products=trenddetails.IHS_Product__r.Name;
                            generator.writeStartObject();
                            if(trenddetails.IHS_Product__r.Name!=null){
                                generator.writeStringField(System.Label.MYBZ_product,trenddetails.IHS_Product__r.Name);
                            }
                            else
                            {    
                                generator.writeNullField(System.Label.MYBZ_product);
                            }
                            generator.writeFieldName(System.Label.MYBZ_topFivePrescribers);
                            generator.writeStartArray();
                            productprescribercount=1;
                        }
                    }
                    
                    //This check is placed to ensure information for only top 5 prescribers is retrieved.
                    if(productprescribercount<=5)
                    {
                        generator.writeStartObject();
                        
                        //Adding the required fields to the JSON
                        
                        if(trenddetails.HCP_First_Name__c!=null){
                            generator.writeStringField(System.Label.MYBZ_prescriberFirstName,trenddetails.HCP_First_Name__c);
                        }
                        else
                        {    
                            generator.writeNullField(System.Label.MYBZ_prescriberFirstName);
                        }
                        if(trenddetails.HCP_Last_Name__c!=null){
                            generator.writeStringField(System.Label.MYBZ_prescriberLastName,trenddetails.HCP_Last_Name__c);
                        }
                        else
                        {    
                            generator.writeNullField(System.Label.MYBZ_prescriberLastName);
                        }
                        if(trenddetails.TRx_Units__c!=null){
                            generator.writeNumberField(System.Label.MYBZ_trx,trenddetails.TRx_Units__c);
                        }
                        else
                        {    
                            generator.writeNullField(System.Label.MYBZ_trx);
                        }
                        generator.writeEndObject();
                        
                        if(productprescribercount==5)
                        {
                            generator.writeEndArray();
                            generator.writeEndObject();
                        }
                        
                        productprescribercount++;
                        
                    }
                    
                }
            }
            generator.writeEndArray();  
            JsonString = generator.getAsString();
            JsonString=JsonString.replaceall('\n','');
            System.Debug('--TrendsPrescriber' + JsonString);
            Object trendsPrescriberObject = Json.deserializeUntyped(JsonString); 
            return trendsPrescriberObject;
        }
        catch(Exception E) 
        {
            system.debug('Exception occurred during execution of TrendPrescriber method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
        
    }
    
    /* 
* @Method Name                    :  marketShareUsingPicker
* @Description                    :  JavaScript remoting to allow MarketShare record of Lilly and Competitor  products to be retrieved from Salesforce in the form of a JSON object in the presence of a territory picker.                                         
* @Return Type                    :  object
* @Param                          :  Region - The region associated to the territory selected, District - The district associated to the territory selected
Territory - The territory selected via a territory picker.  

*/    
    @RemoteAction 
    global static Object marketShareUsingPicker(String region, String district, String territory)
    {
        try{
            // fetching logged in user information like Role,global id etc.
            fetchUserInfo();
            
            // Query for market share records based on the role of logged in user and alignment chosen using territory picker, decides the data available on report
            if((Role == System.Label.MYBZ_MajorMarketManager || Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager  || Role == System.Label.MYBZ_SuperUser) && district !=null && district !=''){
                marketShareList.clear();                
                marketShareList = [SELECT Id, Region__c, District__c, Global_Id__c, Owner__c, Market__c, lillyProduct__c, Month__c, Year__c, Product__r.Name, TRx__c, Previous_Month_TRx__c, DDD_Units__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE District__r.Name =:district AND Territory__c = null ORDER BY Month__c, Year__c ASC];
            }
            if((Role == System.Label.MYBZ_MajorMarketManager || Role == System.Label.MYBZ_SuperUser) && region !=null && region !='' && (district == null || district == '')){
                marketShareList.clear();                
                marketShareList = [SELECT Id, Region__c, District__c, Global_Id__c, Owner__c, Market__c, lillyProduct__c, Month__c, Year__c, Product__r.Name, TRx__c, Previous_Month_TRx__c, DDD_Units__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE Region__r.Name =: region AND District__c = null ORDER BY Month__c, Year__c ASC];
            }
            if((Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager  || Role == System.Label.MYBZ_SuperUser) && territory !=null && territory !=''){
                marketShareList.clear();
                marketShareList = [SELECT Id, Region__c, District__c, Global_Id__c, Owner__c, Market__c, lillyProduct__c, Month__c, Year__c, Product__r.Name, TRx__c, Previous_Month_TRx__c, DDD_Units__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE Territory__r.Name =:territory ORDER BY Month__c, Year__c ASC];
            }
        }
        catch(exception E){     
            system.debug('Exception occurred during execution of MarketShare method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
        
        // Call to method which processes market share JSON based on market share list queried above
        Object marketShareObject = marketShareProcessor();
        System.debug('MarketShareObject--'+marketShareObject);
        return marketShareObject;
    }
    
    /* 
* @Method Name                    :  marketShare
* @Description                    :  JavaScript remoting to allow MarketShare record of Lilly and Competitor products to be retrieved 
from Salesforce in the form of a JSON object based on Global id , without using territory picker
* @Return Type                    :  object
* @Param                          :  

*/    
    @RemoteAction 
    global static Object marketShare()
    {
        try{ 
            // fetching logged in user information like Role,global id etc.
            fetchUserInfo();        
            
            // Query for market share records based on the role of logged in user , decides the data available on report
            if(Role == System.Label.MYBZ_SalesRepresentative){
                marketShareList.clear();
                marketShareList = [SELECT Id, Region__c, District__c, Global_Id__c, Owner__c, Market__c, lillyProduct__c, Month__c, Year__c, Product__r.Name, TRx__c, Previous_Month_TRx__c, DDD_Units__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE Global_Id__c =:GlobalId ORDER BY Month__c, Year__c ASC];
            }
            if(Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager ){
                marketShareList.clear();
                marketShareList = [SELECT Id, Region__c, District__c, Global_Id__c, Owner__c, Market__c, lillyProduct__c, Month__c, Year__c, Product__r.Name, TRx__c, Previous_Month_TRx__c, DDD_Units__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE Global_Id__c =:GlobalId ORDER BY Month__c, Year__c ASC];
            }
            if(Role == System.Label.MYBZ_MajorMarketManager){
                marketShareList.clear();
                marketShareList = [SELECT Id, Region__c, District__c, Global_Id__c, Owner__c, Market__c, lillyProduct__c, Month__c, Year__c, Product__r.Name, TRx__c, Previous_Month_TRx__c, DDD_Units__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE Global_Id__c =:GlobalId ORDER BY Month__c, Year__c ASC];
            }
            if(Role == System.Label.MYBZ_SuperUser){
                marketShareList.clear();
                    MYBZ_Region__c reg=[Select id from MYBZ_Region__c where Name =: System.Label.MYBZ_defaultRegion ];
                    marketShareList = [SELECT Id, Region__c, District__c, Global_Id__c, Owner__c, Market__c, lillyProduct__c, Month__c, Year__c, Product__r.Name, TRx__c, Previous_Month_TRx__c, DDD_Units__c,Previous_DDD_Units__c FROM MYBZ_Market_Share__c WHERE Region__c =:reg.Id and district__c=null ORDER BY Month__c, Year__c ASC];
                
            }
            
        }
        
        
        catch(exception E){     
            system.debug('Exception occurred during execution of MarketShare method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
        
        // Call to method which processes market share JSON based on market share list queried above
        Object marketShareObject = marketShareProcessor();
        System.debug('marketShareObject--'+marketShareObject);
        return marketShareObject;
    }   
    
    /* 
* @Method Name                    :  marketShareProcessor
* @Description                    :  Utility method for creating JSONs associated with marketsahre report                    
* @Return Type                    :  object
* @Param                          :  
*/    
    global static Object marketShareProcessor()
    {   
    
        // Initialization of variables   
        Map<Decimal, Set<Decimal>> YearAndMonthsMap = new Map<Decimal, Set<Decimal>>();
        Map<String, Set<Decimal>> MarketShareNameAndYearMap = new Map<String, Set<Decimal>>();
        Map<String, Map<Decimal, Set<Decimal>>>MarketShareNameAndYearMonthMap = new Map<String, Map<Decimal, Set<Decimal>>>();
        Map<String, Map<Decimal, List<MYBZ_Market_Share__c>>> MarketShareNameAndMarketShareMap = new Map<String, Map<Decimal, List<MYBZ_Market_Share__c>>>();
        
        try{
            //Clear variables so that no remnants from previous call exists
            YearAndMonthsMap.clear();
            MarketShareNameAndYearMap.clear();
            MarketShareNameAndYearMonthMap.clear();
            MarketShareNameAndMarketShareMap.clear();
            
            // creating a map to hold years per marketshare name 
            if(!marketShareList.isEmpty()){
                for(MYBZ_Market_Share__c marketShareObj : marketShareList){
                    if(!MarketShareNameAndYearMap.containsKey(marketShareObj.Market__c)){
                        Set<Decimal> YearSet = new Set<Decimal>();
                        YearSet.add(marketShareObj.Year__c);
                        MarketShareNameAndYearMap.put(marketShareObj.Market__c, YearSet);
                    }
                    else{
                        MarketShareNameAndYearMap.get(marketShareObj.Market__c).add(marketShareObj.Year__c);
                    }
                }
            }
            
            // creating a map to hold months per year for which market share records/data could be found 
            if(!MarketShareNameAndYearMap.isEmpty()){
                for(String marketShareName : MarketShareNameAndYearMap.keySet()){                   
                    for(MYBZ_Market_Share__c marketShareObj : marketShareList){
                        if(marketShareObj.Market__c == marketShareName){
                            Set<Decimal> marketYears = MarketShareNameAndYearMap.get(marketShareName);
                            for(Decimal Year : marketYears){
                                if(marketShareObj.Year__c == Year){
                                    if(!YearAndMonthsMap.containsKey(Year)){
                                        Set<Decimal> MonthsSet = new Set<Decimal>();
                                        MonthsSet.add(marketShareObj.Month__c);
                                        YearAndMonthsMap.put(year, MonthsSet);
                                    }
                                    else{
                                        YearAndMonthsMap.get(year).add(marketShareObj.Month__c);
                                    }
                                }
                            }
                        }
                    }
                    MarketShareNameAndYearMonthMap.put(marketShareName,YearAndMonthsMap);
                }
            }
            
            // creating a map to hold marketshare per year map for each market            
            if(!MarketShareNameAndYearMonthMap.isEmpty()){
                for(String marketShareName : MarketShareNameAndYearMonthMap.keySet()){
                    YearAndMonthsMap = MarketShareNameAndYearMonthMap.get(marketShareName);
                    List<MYBZ_Market_Share__c> marketList = new List<MYBZ_Market_Share__c>();
                    Map<Decimal, List<MYBZ_Market_Share__c>> YearAndMarketShareMap = new Map<Decimal, List<MYBZ_Market_Share__c>>();
                    for(Decimal year : YearAndMonthsMap.keySet()){
                        Set<Decimal>MonthsSet = YearAndMonthsMap.get(year);
                        for(Decimal month : MonthsSet){
                            Map<Decimal, List<MYBZ_Market_Share__c>> MonthAndMarketMap = new Map<Decimal, List<MYBZ_Market_Share__c>>();
                            for(MYBZ_Market_Share__c marketShareObj : marketShareList){
                                if(marketShareObj.Month__c == month && marketShareObj.Year__c == year && marketShareObj.Market__c == marketShareName){
                                    marketList.add(marketShareObj);
                                }
                            }
                        }
                        YearAndMarketShareMap.put(year, marketList);
                    }
                    MarketShareNameAndMarketShareMap.put(marketShareName, YearAndMarketShareMap);
                }
            }
            Object MarketShareObject;
            if(!MarketShareNameAndYearMonthMap.isEmpty() && !MarketShareNameAndMarketShareMap.isEmpty()){
                //Returns a new JSON generator.
                generator = JSON.createGenerator(true);
                //Writes the starting marker of a JSON Object.
                generator.writeStartArray();
                
                // Looping over each unique market 
                for(String marketShareName : MarketShareNameAndMarketShareMap.keySet()){
                    Map<Decimal, Set<Decimal>> YearAndMonthMap = MarketShareNameAndYearMonthMap.get(marketShareName);
                    generator.writeStartObject();
                    generator.writeStringField(System.Label.MYBZ_market,marketShareName);
                    if(MarketShareNameAndMarketShareMap.get(marketShareName) !=null){
                        Map<Decimal, List<MYBZ_Market_Share__c>> YearAndMarketMap = MarketShareNameAndMarketShareMap.get(marketShareName);
                        generator.writeFieldName(System.Label.MYBZ_data);
                        generator.writeStartArray();                            
                        for(Decimal Year : YearAndMarketMap.KeySet()){
                            Set<Decimal>MonthsSet = YearAndMonthMap.get(Year);
                            
                            
                            List<MYBZ_Market_Share__c> marketList =  YearAndMarketMap.get(Year);
                            for(Decimal Month : MonthsSet){
                                generator.writeStartObject();
                                generator.writeNumberField(System.Label.MYBZ_month,Month);
                                generator.writeNumberField(System.Label.MYBZ_Year,Year);
                                if(!marketList.isEmpty()){
                                    generator.writeFieldName(System.Label.MYBZ_Products);
                                    generator.writeStartArray();
                                    for(MYBZ_Market_Share__c marketShareObj : marketList){
                                        Decimal percentageChangeSinceLastMonth;
                                        if(marketShareObj.Market__c == marketShareName && marketShareObj.Year__c == Year && marketShareObj.Month__c == Month){
                                            generator.writeStartObject();
                                            if(marketShareObj.TRx__c !=null){
                                                generator.writeNumberField(System.Label.MYBZ_trx,marketShareObj.TRx__c);
                                            }
                                            else
                                                
                                            {    
                                                generator.writeNullField(System.Label.MYBZ_trx);
                                            }
                                            if(marketShareObj.Previous_Month_TRx__c!=null){
                                                if(marketShareObj.Previous_Month_TRx__c !=0){
                                                    percentageChangeSinceLastMonth = ((marketShareObj.TRx__c - marketShareObj.Previous_Month_TRx__c) / marketShareObj.Previous_Month_TRx__c);
                                                    percentageChangeSinceLastMonth = percentageChangeSinceLastMonth.SetScale(2,RoundingMode.CEILING);
                                                }
                                                else{
                                                    percentageChangeSinceLastMonth = 0;
                                                }
                                                generator.writeNumberField(System.Label.MYBZ_percentageChangeFromPreviousMonthTRx,percentageChangeSinceLastMonth);
                                            }
                                            else
                                                generator.writeNullField(System.Label.MYBZ_percentageChangeFromPreviousMonthTRx);
                                            generator.writeStringField(System.Label.MYBZ_productName,marketShareObj.Product__r.Name);
                                            generator.writeBooleanField(System.Label.MYBZ_lillyProduct,marketShareObj.lillyProduct__c);
                                            
                                            if(marketShareObj.DDD_Units__c!=null){
                                                generator.writeNumberField(System.Label.MYBZ_dddUnits,marketShareObj.DDD_Units__c);
                                            }
                                            else
                                            {    
                                                generator.writeNullField(System.Label.MYBZ_dddUnits);
                                            }
                                            
                                            if(marketShareObj.Previous_DDD_Units__c!=null)
                                            {
                                                if(marketShareObj.Previous_DDD_Units__c!=0)
                                                {
                                                    PercentageChangeDDDUnits = ((marketShareObj.DDD_Units__c - marketShareObj.Previous_DDD_Units__c)/marketShareObj.Previous_DDD_Units__c);
                                                    PercentageChangeDDDUnits = PercentageChangeDDDUnits.SetScale(2,RoundingMode.CEILING);
                                                }
                                                else
                                                {
                                                    PercentageChangeDDDUnits=0;
                                                }
                                                generator.writeNumberField(System.Label.MYBZ_percentageChangeFromPreviousMonthDDDUnits,PercentageChangeDDDUnits);   
                                            }
                                            else
                                                generator.writeNullField(System.Label.MYBZ_percentageChangeFromPreviousMonthDDDUnits);
                                            
                                            generator.writeEndObject();
                                            
                                        }
                                        
                                    }
                                    generator.writeEndArray();
                                }
                                generator.writeEndObject();
                            }
                        }
                        
                        generator.writeEndArray();
                    }
                    generator.writeEndObject();
                }
                generator.writeEndArray();
                JsonString = generator.getAsString();
                System.debug('--MarketShare'+JsonString);
                MarketShareObject = Json.deserializeUntyped(JsonString);
                
            }
            return MarketShareObject;
            
        }
        catch(Exception E) 
        {
            system.debug('Exception occurred during execution of Marketshare Processor method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
    } 
    
    
    /* 
* @Method Name                    :  targetGoalUsingPicker
* @Description                    :  JavaScript remoting to allow TargetGoal record associated with particular district to be retrieved from Salesforce in the form of a JSON object                                         
* @Return Type                    :  object
* @Param                          :   Region - The region associated to the territory selected, District - The district associated to the territory selected
Territory - The territory selected via a territory picker.  

*/    
    @RemoteAction 
    global static Object targetGoalUsingPicker(String region, String district, String territory)
    {   
        try{
            // fetching logged in user information like Role,global id etc.
            fetchUserInfo();
            
            // Query for target Goal records based on the role of logged in user and alignment chosen using territory picker, decides the data available on report
            if((Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager) && district != null && district != ''){
                targetGoalList.clear();
                targetGoalList = [SELECT Id, Baseline__c,actualDddUnits__c,Product_Weight_DDD__c,Product_Weight_TRx__c ,Global_Id__c, Month__c, Year__c, Product__r.Name, TRx_Goal__c, TRx_Goal_Attainment__c FROM MYBZ_Target_Goal__c WHERE District__r.Name =:district AND Territory__c = null   ORDER BY Month__c, Year__c ASC ];
            }
            if((Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager) && territory != null && territory != ''){
                targetGoalList.clear();
                targetGoalList = [SELECT Id, Baseline__c,actualDddUnits__c,Product_Weight_DDD__c,Product_Weight_TRx__c ,Global_Id__c, Month__c, Year__c, Product__r.Name, TRx_Goal__c, TRx_Goal_Attainment__c FROM MYBZ_Target_Goal__c WHERE Territory__r.Name =: territory ORDER BY Month__c, Year__c ASC ];
            }
            if(Role == System.Label.MYBZ_MajorMarketManager && district !=null && district !=''){
                targetGoalList.clear();
                targetGoalList = [SELECT Id, Baseline__c,actualDddUnits__c,Product_Weight_DDD__c,Product_Weight_TRx__c ,Global_Id__c, Month__c, Year__c, Product__r.Name, TRx_Goal__c, TRx_Goal_Attainment__c FROM MYBZ_Target_Goal__c WHERE District__r.Name =:district AND Territory__c = null ORDER BY Month__c, Year__c ASC];
            }
            if(Role == System.Label.MYBZ_SuperUser && district != null && district != ''){
                targetGoalList.clear();
                targetGoalList = [SELECT Id,Baseline__c,actualDddUnits__c,Product_Weight_DDD__c,Product_Weight_TRx__c , Global_Id__c, Month__c, Year__c, Product__r.Name, TRx_Goal__c, TRx_Goal_Attainment__c FROM MYBZ_Target_Goal__c WHERE District__r.Name =:district AND Territory__c = null ORDER BY Month__c, Year__c ASC];
            }
            if(Role == System.Label.MYBZ_SuperUser && territory != null && territory != ''){
                targetGoalList.clear();
                targetGoalList = [SELECT Id, Baseline__c,actualDddUnits__c,Product_Weight_DDD__c,Product_Weight_TRx__c ,Global_Id__c, Month__c, Year__c, Product__r.Name, TRx_Goal__c, TRx_Goal_Attainment__c FROM MYBZ_Target_Goal__c WHERE Territory__r.Name =: territory ORDER BY Month__c, Year__c ASC ];
            }
        }    
        catch(Exception E){
            system.debug('Exception occurred during execution of Target Goal method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
            
        }
        
        
        
        // Call to method which processes target Goal JSON based on target goal list queried above
        Object targetGoalObject = targetGoalProcessor();
        System.debug('TargetGoalObject--'+targetGoalObject);
        return targetGoalObject;
        
    }
    
    /* 
* @Method Name                    :  TargetGoal
* @Description                    :  JavaScript remoting to allow TargetGoal record associated with particular district to be retrieved from Salesforce in the form of a JSON object                                         
* @Return Type                    :  object
* @Param                          :   

*/    
    @RemoteAction 
    global static Object targetGoal()
    {
        try{
            // fetching logged in user information like Role,global id etc.
            fetchUserInfo();
            
            // Query for target Goal records based on the role of logged in user, decides the data available on report
            if((Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager)){
                targetGoalList.clear();
                targetGoalList = [SELECT Id,Baseline__c,actualDddUnits__c,Product_Weight_DDD__c,Product_Weight_TRx__c , Global_Id__c, Month__c, Year__c, Product__r.Name, TRx_Goal__c, TRx_Goal_Attainment__c FROM MYBZ_Target_Goal__c WHERE Global_Id__c =:GlobalId AND Territory__c = null ORDER BY Month__c, Year__c ASC];
            }
            else if(Role == System.Label.MYBZ_MajorMarketManager){
                targetGoalList.clear();
                MYBZ_Region_Rollup__c regionRollupObj = [SELECT Id, District__c FROM MYBZ_Region_Rollup__c WHERE Global_Id__c =:GlobalId LIMIT 1];
                
                targetGoalList = [SELECT Id, Baseline__c,actualDddUnits__c,Product_Weight_DDD__c,Product_Weight_TRx__c ,Global_Id__c, Month__c, Year__c, Product__r.Name, TRx_Goal__c, TRx_Goal_Attainment__c FROM MYBZ_Target_Goal__c WHERE District__c =:regionRollupObj.District__c AND Territory__c = null ORDER BY Month__c, Year__c ASC];
            }
            else if(Role == System.Label.MYBZ_SalesRepresentative){
                targetGoalList.clear();
                targetGoalList = [SELECT Id, Baseline__c,actualDddUnits__c,Product_Weight_DDD__c,Product_Weight_TRx__c ,Global_Id__c, Month__c, Year__c, Product__r.Name, TRx_Goal__c, TRx_Goal_Attainment__c FROM MYBZ_Target_Goal__c WHERE Global_Id__c =:GlobalId ORDER BY Month__c, Year__c ASC];
                
            }
            else if(Role == System.Label.MYBZ_SuperUser){
                targetGoalList.clear();  
                MYBZ_District__c districtObj = [SELECT Id FROM MYBZ_District__c LIMIT 1];
                if(districtObj!=null){
                    targetGoalList = [SELECT Id, Baseline__c,actualDddUnits__c,Product_Weight_DDD__c,Product_Weight_TRx__c ,Global_Id__c, Month__c, Year__c, Product__r.Name, TRx_Goal__c, TRx_Goal_Attainment__c FROM MYBZ_Target_Goal__c WHERE District__c =:districtObj.Id AND Territory__c = null ORDER BY Month__c, Year__c ASC];
                }
            }
        }
        catch(Exception E){
            system.debug('Exception occurred during execution of Target Goal method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
        // Call to method which processes target Goal JSON based on target goal list queried above
        Object targetGoalObject = targetGoalProcessor();
        System.debug('TargetGoalObject--'+targetGoalObject);
        return targetGoalObject;
    }
    
    /* 
* @Method Name                    :  targetGoalProcessor
* @Description                    :  Utility method for creating JSONS associated with Target Goal Report
* @Return Type                    :  object
* @Param                          :   */    

    global static Object targetGoalProcessor()
    {
        // Map variable to collate data set of months associated with each year for which target goal records are found
        Map<Decimal, Set<Decimal>> YearAndMonthsMap = new Map<Decimal, Set<Decimal>>();
                try{
            if(!targetGoalList.isEmpty()){
                for(MYBZ_Target_Goal__c targetGoalObj : targetGoalList){
                    targetGoalYear.add(targetGoalObj.Year__c);
                }
            }
            if(!targetGoalYear.isEmpty()){
                for(Decimal year : targetGoalYear){
                    for(MYBZ_Target_Goal__c targetGoalObj : targetGoalList){
                        if(targetGoalObj.Year__c == year){
                            if(!YearAndMonthsMap.containsKey(year)){
                                Set<Decimal> MonthsSet = new Set<Decimal>();
                                MonthsSet.add(targetGoalObj.Month__c);
                                YearAndMonthsMap.put(year, MonthsSet);
                            }
                            else{
                                YearAndMonthsMap.get(year).add(targetGoalObj.Month__c);
                            }
                        }
                    }
                }
            }
            if(!targetGoalYear.isEmpty() && !YearAndMonthsMap.isEmpty()){
                for(Decimal year : targetGoalYear){
                    Map<Decimal, List<MYBZ_Target_Goal__c>> MonthAndTargetGoalMap = new Map<Decimal, List<MYBZ_Target_Goal__c>>();
                    if(YearAndMonthsMap.containsKey(year)){
                        for(Decimal month : YearAndMonthsMap.get(year)){
                            List<MYBZ_Target_Goal__c> targetGoalMonthList = new List<MYBZ_Target_Goal__c>();
                            for(MYBZ_Target_Goal__c targetGoalObj : targetGoalList){
                                if(targetGoalObj.Month__c == month && targetGoalObj.Year__c == year){
                                    targetGoalMonthList.add(targetGoalObj);
                                }
                            }
                            MonthAndTargetGoalMap.put(month, targetGoalMonthList);
                        }
                    }
                    YearAndMonthTargetGoalMap.put(year, MonthAndTargetGoalMap);
                }
            }
            object TargetGoalObject;
            if(!targetGoalYear.isEmpty() && !YearAndMonthTargetGoalMap.isEmpty()){
                generator = JSON.createGenerator(true);
                generator.writeStartArray();
                for(Decimal year : targetGoalYear){
                    if(YearAndMonthTargetGoalMap.containsKey(year)){
                        Map<Decimal, List<MYBZ_Target_Goal__c>> TempMonthAndTargetGoalMap = YearAndMonthTargetGoalMap.get(year);
                        for(Decimal month : TempMonthAndTargetGoalMap.keySet()){
                            generator.writeStartObject();
                            generator.writeNumberField(System.Label.MYBZ_month,month);
                            generator.writeNumberField(System.Label.MYBZ_Year,year);
                            if(TempMonthAndTargetGoalMap.get(month) !=null){
                                generator.writeFieldName(System.Label.MYBZ_goals);
                                generator.writeStartArray();
                                for(MYBZ_Target_Goal__c targetGoalObj : TempMonthAndTargetGoalMap.get(month)){
                                    generator.writeStartObject();
                                    generator.writeStringField(System.Label.MYBZ_productName,targetGoalObj.Product__r.Name);
                                     if(targetGoalObj.TRx_Goal__c !=null)
                                        generator.writeNumberField(System.Label.MYBZ_goalSet,targetGoalObj.TRx_Goal__c);
                                    else
                                        generator.writeNullField(System.Label.MYBZ_goalSet);
                                    if(targetGoalObj.TRx_Goal_Attainment__c !=null)
                                        generator.writeNumberField(System.Label.MYBZ_goalMet,targetGoalObj.TRx_Goal_Attainment__c);
                                    else
                                        generator.writeNullField(System.Label.MYBZ_goalMet);
                                    if(targetGoalObj.Baseline__c !=null)
                                        generator.writeNumberField(System.Label.MYBZ_Baseline,targetGoalObj.Baseline__c);
                                   else
                                       generator.writeNullField(System.Label.MYBZ_Baseline);
                                   if(targetGoalObj.actualDddUnits__c !=null)
                                        generator.writeNumberField(System.Label.MYBZ_actualDddUnits,targetGoalObj.actualDddUnits__c);
                                   else
                                       generator.writeNullField(System.Label.MYBZ_actualDddUnits);
                                    if(targetGoalObj.Product_Weight_DDD__c !=null)
                                     generator.writeNumberField(System.Label.MYBZ_Product_Weight_DDD_c,targetGoalObj.Product_Weight_DDD__c);
                                   else
                                       generator.writeNullField(System.Label.MYBZ_Product_Weight_DDD_c);
                                    if(targetGoalObj.Product_Weight_TRx__c !=null)
                                     generator.writeNumberField(System.Label.MYBZ_Product_Weight_TRx,targetGoalObj.Product_Weight_TRx__c);
                                    else
                                       generator.writeNullField(System.Label.MYBZ_Product_Weight_TRx);
                                    generator.writeEndObject();
                                }
                                generator.writeEndArray();
                            }
                            generator.writeEndObject();
                        }
                    }
                }
                generator.writeEndArray();
                JsonString = generator.getAsString();
                System.debug('--TargetGoal1'+JsonString);
                TargetGoalObject = Json.deserializeUntyped(JsonString);
            }
            return TargetGoalObject;
        }
        catch(Exception E)
        {
            system.debug('Exception occurred during execution of TargetGoal Processor method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }

    }  
    
    /* 
* @Method Name                    :  callPlanning
* @Description                    :  JavaScript remoting to allow Call Planning record for each prescriber as well as calls associated to the same prescriber
to be retrieved from Salesforce in the form of a JSON object in the presence of a territory picker.                                         
* @Return Type                    :  object
* @Param                          :  Region - The region associated to the territory selected, District - The district associated to the territory selected
Territory - The territory selected via a territory picker.   

*/    
    @RemoteAction 
    global static Object callPlanningUsingPicker(String region, String district, String territory)
    {       
        try{   
            
            fetchUserInfo();      
            if(Role == System.Label.MYBZ_SalesRepresentative){
                CallPlanningsList.clear();
                CallPlanningsList = [Select Call_Planning__c,Call_Planning__r.Physician_ID__c,Call_Planning__r.Global_ID__c,Call_Planning__r.First_Name__c,Call_Planning__r.Last_Name__c,Call_Planning__r.Tier__c,Product__c,Product__r.name,TRx_Units_1M__c, TRx_Units_3M__c, TRx_Units_6M__c, Previous_TRx_Units_1M__c, Previous_TRx_Units_3M__c, Previous_TRx_Units_6M__c, Call_Planning__r.Start_Date_1M__c, Call_Planning__r.Start_Date_3M__c, Call_Planning__r.Start_Date_6M__c from MYBZ_CallPlanningProductJunction__c where Call_Planning__r.Global_ID__c=:GlobalId order by Call_Planning__r.Physician_ID__c,Product__r.Name];
                CallsList = [select Name,Global_ID__c,First_Name__c,Last_Name__c,Physician_ID__c, Call_ID__c,Call_Type__c,Product_Position__c,Call_Date__c, Product__c,Product__r.Name from MYBZ_Call__c where Global_ID__c=:GlobalId order by Physician_ID__c,Call_Date__c desc,Call_ID__c asc, Product_Position__c asc ];
                
            }
            if((Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager  || Role == System.Label.MYBZ_SuperUser) && territory != null && territory !=''){
                CallPlanningsList.clear();
                CallPlanningsList = [Select Call_Planning__c,Call_Planning__r.Physician_ID__c,Call_Planning__r.Global_ID__c,Call_Planning__r.First_Name__c,Call_Planning__r.Last_Name__c,Call_Planning__r.Tier__c,Call_Planning__r.Territory__r.Name, Product__c,Product__r.name,TRx_Units_1M__c, TRx_Units_3M__c, TRx_Units_6M__c, Previous_TRx_Units_1M__c, Previous_TRx_Units_3M__c, Previous_TRx_Units_6M__c,Call_Planning__r.Start_Date_1M__c, Call_Planning__r.Start_Date_3M__c, Call_Planning__r.Start_Date_6M__c from MYBZ_CallPlanningProductJunction__c where Call_Planning__r.Territory__r.Name=:territory order by Call_Planning__r.Physician_ID__c,Product__r.Name];
                CallsList = [select Name,Global_ID__c,First_Name__c,Last_Name__c,Physician_ID__c, Call_ID__c,Call_Type__c,Product_Position__c,Call_Date__c, Product__c,Product__r.Name,Territory__c,Territory__r.Name from MYBZ_Call__c where Territory__r.Name=:territory order by Physician_ID__c,Call_Date__c desc,Call_ID__c asc, Product_Position__c asc ];
            }
            if(Role == System.Label.MYBZ_MajorMarketManager){
                CallPlanningsList.clear();
                MYBZ_Region_Rollup__c territoryObj = [SELECT Id, Global_Id__c FROM MYBZ_Region_Rollup__c WHERE Alignment_Level__c = :System.Label.MYBZ_Territory LIMIT 1];
                CallPlanningsList = [Select Call_Planning__c,Call_Planning__r.Physician_ID__c,Call_Planning__r.Global_ID__c,Call_Planning__r.First_Name__c,Call_Planning__r.Last_Name__c,Call_Planning__r.Tier__c,Product__c,Product__r.name,TRx_Units_1M__c, TRx_Units_3M__c, TRx_Units_6M__c, Previous_TRx_Units_1M__c, Previous_TRx_Units_3M__c, Previous_TRx_Units_6M__c, Call_Planning__r.Start_Date_1M__c, Call_Planning__r.Start_Date_3M__c, Call_Planning__r.Start_Date_6M__c from MYBZ_CallPlanningProductJunction__c where Call_Planning__r.Global_ID__c=:territoryObj.Global_Id__c order by Call_Planning__r.Physician_ID__c,Product__r.Name];
            }
            
        }
        Catch(Exception e)
        {
            system.debug('Exception occurred during execution of TargetGoal Processor method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
        Object callPlanningObject = callPlanningProcessor();
        System.debug('callPlanningObject--'+callPlanningObject);
        return callPlanningObject; 
    }
    
    /* 
* @Method Name                    :  callPlanning
* @Description                    :  JavaScript remoting to allow Call Planning record for each prescriber as well as calls associated to the same prescriber
to be retrieved from Salesforce in the form of a JSON object in the absence of a territory picker.                                          
* @Return Type                    :  object
* @Param                          :   */
    
    @RemoteAction 
    global static Object callPlanning()
    {       
        try{    
            fetchUserInfo();
            if(Role == System.Label.MYBZ_MajorMarketManager || Role == System.Label.MYBZ_SuperUser){
                CallPlanningsList.clear();                
                MYBZ_Region_Rollup__c territoryObj = [SELECT Id, Global_Id__c FROM MYBZ_Region_Rollup__c WHERE Alignment_Level__c = :System.Label.MYBZ_Territory LIMIT 1];
                if(territoryObj!=null){ 
                    CallPlanningsList = [Select Call_Planning__c,Call_Planning__r.Physician_ID__c,Call_Planning__r.Global_ID__c,Call_Planning__r.First_Name__c,Call_Planning__r.Last_Name__c,Call_Planning__r.Tier__c,Product__c,Product__r.name,TRx_Units_1M__c, TRx_Units_3M__c, TRx_Units_6M__c, Previous_TRx_Units_1M__c, Previous_TRx_Units_3M__c, Previous_TRx_Units_6M__c,Call_Planning__r.Start_Date_1M__c, Call_Planning__r.Start_Date_3M__c, Call_Planning__r.Start_Date_6M__c from MYBZ_CallPlanningProductJunction__c where Call_Planning__r.Global_ID__c=:territoryObj.Global_Id__c order by Call_Planning__r.Physician_ID__c,Product__r.Name];
                }
            }
            if(Role == System.Label.MYBZ_DistrictSalesManager || Role == System.Label.MYBZ_AccountManager ){
                CallPlanningsList.clear();                
                MYBZ_Region_Rollup__c districtObj = [SELECT Id, District__c FROM MYBZ_Region_Rollup__c WHERE Global_Id__c =:GlobalId LIMIT 1];
                if(districtObj!=null){
                    MYBZ_Region_Rollup__c territoryObj = [SELECT Id, Name, Global_Id__c FROM MYBZ_Region_Rollup__c WHERE District__c =:districtObj.District__c AND Global_Id__c !=null AND Global_Id__c !='' LIMIT 1];
                    if(territoryObj!=null){
                        CallPlanningsList = [Select Call_Planning__c,Call_Planning__r.Physician_ID__c,Call_Planning__r.Global_ID__c,Call_Planning__r.First_Name__c,Call_Planning__r.Last_Name__c,Call_Planning__r.Tier__c,Product__c,Product__r.name,TRx_Units_1M__c, TRx_Units_3M__c, TRx_Units_6M__c, Previous_TRx_Units_1M__c, Previous_TRx_Units_3M__c, Previous_TRx_Units_6M__c, Call_Planning__r.Start_Date_1M__c, Call_Planning__r.Start_Date_3M__c, Call_Planning__r.Start_Date_6M__c from MYBZ_CallPlanningProductJunction__c where Call_Planning__r.Global_ID__c=:territoryObj.Global_Id__c order by Call_Planning__r.Physician_ID__c,Product__r.Name];
                    }
                }
            }
            if(Role == System.Label.MYBZ_SalesRepresentative){
                CallPlanningsList.clear();
                CallPlanningsList = [Select Call_Planning__c,Call_Planning__r.Physician_ID__c,Call_Planning__r.Global_ID__c,Call_Planning__r.First_Name__c,Call_Planning__r.Last_Name__c,Call_Planning__r.Tier__c,Product__c,Product__r.name,TRx_Units_1M__c, TRx_Units_3M__c, TRx_Units_6M__c, Previous_TRx_Units_1M__c, Previous_TRx_Units_3M__c, Previous_TRx_Units_6M__c, Call_Planning__r.Start_Date_1M__c, Call_Planning__r.Start_Date_3M__c, Call_Planning__r.Start_Date_6M__c from MYBZ_CallPlanningProductJunction__c where Call_Planning__r.Global_ID__c=:GlobalId order by Call_Planning__r.Physician_ID__c,Product__r.Name];
                CallsList = [select Name,Global_ID__c,First_Name__c,Last_Name__c,Physician_ID__c, Call_ID__c,Call_Type__c,Product_Position__c,Call_Date__c, Product__c,Product__r.Name from MYBZ_Call__c where Global_ID__c=:GlobalId order by Physician_ID__c,Call_Date__c desc,Call_ID__c asc, Product_Position__c asc ];
            }
        }
        Catch(Exception e)
        {
            system.debug('Exception occurred during execution of Processor method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
        
        Object callPlanningObject = callPlanningProcessor();
        System.debug('callPlanningObject--'+callPlanningObject);
        return callPlanningObject; 
    }
    
    /* 
* @Method Name                    :  CallPlanningProcessor
* @Description                    :  Utility method for Creating JSONs associated with Call planning Report                                         
* @Return Type                    :  object
* @Param                          :   

*/
    
    global static Object callPlanningProcessor(){
        try{
            if(CallPlanningsList.isempty())
            {
                return null;
            } 
            
            //Initialization of variables            
            //Used to track percentage change values over different ranges.
            Decimal percentageChangePastMonth = 0;
            Decimal percentageChangePastThreeMonths = 0;
            Decimal percentageChangePastSixMonths = 0;
            
            //Tracks if the current record is the first physician record or not.
            Integer firstuserflag=1;
            
            //Tracks if the product has been encountered for the first time for a new physician.
            Integer firstproduct=1;
            
            //Tracks if a new product is encountered for the current physician.
            Integer newproduct=1;
            
            //Tracks the first call record.
            Integer firstCall=1;
            
            //Tracks the call count related to each physician.
            Integer usercallcount=0;
            
            //Initializing PhysicianID as blank. This variable is used to keep track of the PhysicianID as we iterate over call planning and call records.
            String PhysicianID ='';
            
            //String CallID='';
            
            //Initializing CurrentProduct as blank for each new physician.
            String CurrentProduct='';
            
            //Initializing currentCallID as blank. This variable is used to keep track of call IDs as we iterate over the call records.
            String currentCallID='';
            
            //Used to store created JSON in string format
            JsonString ='';
            
            //Tracks if a new call record is encountered.
            Integer newCallID=0;
            
            //Keeps track of the number of call records for each new CallID.
            Integer callsProductNumber = 1;
            
            //Temporary variable to allow us to restore the call count in case end of the call records list is reached. 
            Integer InitialCallCount=0;
            
            //Keeps track of the calls count while iterating over the call records.
            Integer CallsCount=0;
            
            //Returns a new JSON generator.
            generator = JSON.createGenerator(true);
            
            
            
            //Writes the starting marker of a JSON Object.
            generator.writeStartObject();  
            if(CallPlanningsList[0].Call_Planning__r.Start_Date_1M__c!=null){
                generator.writeStringField('startDate1Month',CallPlanningsList[0].Call_Planning__r.Start_Date_1M__c.format(System.Label.MYBZ_DateFormat));
            }
            else
            {
                
                generator.writeNullField('startDate1Month');
            }
            if(CallPlanningsList[0].Call_Planning__r.Start_Date_3M__c!=null){
                generator.writeStringField('startDate3Month',CallPlanningsList[0].Call_Planning__r.Start_Date_3M__c.format(System.Label.MYBZ_DateFormat));
            }
            else
            {
                
                generator.writeNullField('startDate3Month');
            }
            if(CallPlanningsList[0].Call_Planning__r.Start_Date_6M__c!=null){
                generator.writeStringField('startDate6Month',CallPlanningsList[0].Call_Planning__r.Start_Date_6M__c.format(System.Label.MYBZ_DateFormat));
            }
            else
            {    
                generator.writeNullField('startDate6Month');
            }
            generator.writeFieldName('data');    
            
            generator.writeStartArray();
            
            //Loop to iterate over all call planning records.
            for(Integer CallPlanningCount=0;CallPlanningCount<CallPlanningsList.size();CallPlanningCount++)
            {
                
                //Determine if a new physician is encountered.
                if(!PhysicianID.equals(CallPlanningsList[CallPlanningCount].Call_Planning__r.Physician_ID__c))
                {
                    
                    
                    //Initializing currentCallID as blank for each new physician
                    currentCallID ='';
                    
                    //Initializing CurrentProduct as blank for each new physician  
                    CurrentProduct='';
                    
                    PhysicianID=CallPlanningsList[CallPlanningCount].Call_Planning__r.Physician_ID__c;
                    
                    //If a new physician record is encountered, start the object else, end the previous object first.
                    if(firstuserflag==1)
                    {
                        
                        generator.writeStartObject();
                        firstuserflag=0;
                    }
                    else
                    {
                        generator.writeEndObject();
                        generator.writeStartObject();
                    }
                    
                    //Write the necessary JSON fields
                    
                    if(CallPlanningsList[CallPlanningCount].Call_Planning__r.First_Name__c!=null){
                        generator.writeStringField(System.Label.MYBZ_FirstName,CallPlanningsList[CallPlanningCount].Call_Planning__r.First_Name__c);
                    }
                    else
                    {    
                        generator.writeNullField(System.Label.MYBZ_FirstName);
                    }
                    if(CallPlanningsList[CallPlanningCount].Call_Planning__r.Last_Name__c!=null){
                        generator.writeStringField(System.Label.MYBZ_LastName,CallPlanningsList[CallPlanningCount].Call_Planning__r.Last_Name__c);
                    }
                    else
                    {
                        
                        generator.writeNullField(System.Label.MYBZ_LastName);
                    }
                    if(CallPlanningsList[CallPlanningCount].Call_Planning__r.Tier__c!=null){
                        generator.writeStringField(System.Label.MYBZ_Tier,String.ValueOf(CallPlanningsList[CallPlanningCount].Call_Planning__r.Tier__c));
                    }
                    else
                    {    
                        
                        generator.writeNullField(System.Label.MYBZ_Tier);
                    }
                    generator.writeFieldName(System.Label.MYBZ_Products);
                    generator.writeStartArray();
                    
                    firstproduct = 1;
                }   
                
                //PRODUCTS
                //To check if a new product has been encountered for the current physician
                
                if(CallPlanningsList[CallPlanningCount].Product__c!=null)
                {
                    if(!CurrentProduct.equals(CallPlanningsList[CallPlanningCount].Product__r.Name))
                    {
                        newproduct=1;
                        percentageChangePastMonth=0;
                        percentageChangePastThreeMonths=0;
                        percentageChangePastSixMonths=0;
                        CurrentProduct = CallPlanningsList[CallPlanningCount].Product__r.Name;
                        
                        //Determines if the product has been encountered for the first time for the current physician
                        
                        if(firstproduct==1)
                        {
                            generator.writeStartObject();
                            firstproduct=0;
                        }
                        else
                        {
                            generator.writeEndObject();
                            generator.writeStartObject();
                        }
                    }
                    else
                    {
                        newproduct=0;
                    }
                }
                else
                {
                    newproduct=1;
                    percentageChangePastMonth=0;
                    percentageChangePastThreeMonths=0;
                    percentageChangePastSixMonths=0;
                    CurrentProduct =''; 
                    if(firstproduct==1)
                    {
                        generator.writeStartObject();
                        firstproduct=0;
                    }
                    else
                    {
                        generator.writeEndObject();
                        generator.writeStartObject();
                    }     
                }
                
                if(newproduct==1)
                {
                    if(CallPlanningsList[CallPlanningCount].Product__r.Name!=null)
                        generator.writeStringField(System.Label.MYBZ_Name,CallPlanningsList[CallPlanningCount].Product__r.Name);
                    
                    else
                        
                        generator.writeNullField(System.Label.MYBZ_Name);
                    
                }
                
                //Adding TRx values to the JSON if they are not null.
                
                if(CallPlanningsList[CallPlanningCount].TRx_Units_1M__c!=null){
                    generator.writeNumberField(System.Label.MYBZ_ScriptsWrittenPastMonth,CallPlanningsList[CallPlanningCount].TRx_Units_1M__c);
                }
                else
                {    
                    
                    generator.writeNullField(System.Label.MYBZ_ScriptsWrittenPastMonth);
                }
                if(CallPlanningsList[CallPlanningCount].TRx_Units_3M__c!=null){
                    generator.writeNumberField(System.Label.MYBZ_ScriptsWrittenPastThreeMonths,CallPlanningsList[CallPlanningCount].TRx_Units_3M__c);
                }
                else
                { 
                    
                    generator.writeNullField(System.Label.MYBZ_ScriptsWrittenPastThreeMonths);
                }
                if(CallPlanningsList[CallPlanningCount].TRx_Units_6M__c!=null){
                    generator.writeNumberField(System.Label.MYBZ_ScriptsWrittenPastSixMonths,CallPlanningsList[CallPlanningCount].TRx_Units_6M__c);
                }
                else
                {
                    generator.writeNullField(System.Label.MYBZ_ScriptsWrittenPastSixMonths);
                }
                if(CallPlanningsList[CallPlanningCount].Previous_TRx_Units_1M__c!=null)
                {
                    if(CallPlanningsList[CallPlanningCount].Previous_TRx_Units_1M__c!=0&&CallPlanningsList[CallPlanningCount].Previous_TRx_Units_1M__c!=-1)
                    {
                        percentageChangePastMonth=((CallPlanningsList[CallPlanningCount].TRx_Units_1M__c-CallPlanningsList[CallPlanningCount].Previous_TRx_Units_1M__c)/CallPlanningsList[CallPlanningCount].Previous_TRx_Units_1M__c)*100;
                        percentageChangePastMonth=percentageChangePastMonth.SetScale(2,RoundingMode.CEILING);
                    }
                    else
                    {
                        percentageChangePastMonth=0;
                    }
                    generator.writeNumberField(System.Label.MYBZ_PercentageChangePastMonth,percentageChangePastMonth);
                }
                else
                    generator.writeNullField(System.Label.MYBZ_PercentageChangePastMonth);
                
                if(CallPlanningsList[CallPlanningCount].Previous_TRx_Units_3M__c!=null)
                {
                    if(CallPlanningsList[CallPlanningCount].Previous_TRx_Units_3M__c!=0&&CallPlanningsList[CallPlanningCount].Previous_TRx_Units_3M__c!=-1)
                    {
                        percentageChangePastThreeMonths=((CallPlanningsList[CallPlanningCount].TRx_Units_3M__c-CallPlanningsList[CallPlanningCount].Previous_TRx_Units_3M__c)/CallPlanningsList[CallPlanningCount].Previous_TRx_Units_3M__c)*100;
                        percentageChangePastThreeMonths=percentageChangePastThreeMonths.SetScale(2,RoundingMode.CEILING);
                    }
                    else
                    {
                        percentageChangePastThreeMonths=0;
                    }
                    generator.writeNumberField(System.Label.MYBZ_PercentageChangePastThreeMonths,percentageChangePastThreeMonths);
                }
                else
                    generator.writeNullField(System.Label.MYBZ_PercentageChangePastThreeMonths);  
                
                if(CallPlanningsList[CallPlanningCount].Previous_TRx_Units_6M__c!=null)
                {
                    if(CallPlanningsList[CallPlanningCount].Previous_TRx_Units_6M__c!=0&&CallPlanningsList[CallPlanningCount].Previous_TRx_Units_6M__c!=-1)
                    {
                        percentageChangePastSixMonths=((CallPlanningsList[CallPlanningCount].TRx_Units_6M__c-CallPlanningsList[CallPlanningCount].Previous_TRx_Units_6M__c)/CallPlanningsList[CallPlanningCount].Previous_TRx_Units_6M__c)*100;
                        percentageChangePastSixMonths=percentageChangePastSixMonths.SetScale(2,RoundingMode.CEILING);
                    }
                    else
                    {
                        percentageChangePastSixMonths=0;
                    }
                    generator.writeNumberField(System.Label.MYBZ_PercentageChangePastSixMonths,percentageChangePastSixMonths);
                }
                else
                    generator.writeNullField(System.Label.MYBZ_PercentageChangePastSixMonths);           
                if((CallPlanningCount+1 == CallPlanningsList.size() )||(!PhysicianID.equals(CallPlanningsList[CallPlanningCount+1].Call_Planning__r.Physician_ID__c)))
                {
                    generator.writeEndObject();
                    generator.writeEndArray();
                    
                    InitialCallCount=CallsCount;
                    
                    //If the current call record does not correspond to the current call planning record, go to the next call record. If end of the calls list is reached, restore the callscount.
                    
                    if(CallsCount<CallsList.Size()&&(!PhysicianID.equals(CallsList[CallsCount].Physician_ID__c)))
                    {
                        for(integer a=CallsCount;a<CallsList.Size();a++)
                        {
                            if(!PhysicianID.equals(CallsList[CallsCount].Physician_ID__c))
                            {
                                CallsCount++;
                            }
                            else
                            {
                                break;
                            }
                        }
                        if(CallsCount==CallsList.size())
                        {
                            CallsCount=InitialCallCount;
                        }
                    }
                    
                    //If the current call record corresponds to the current call planning record, write the required JSON fields.
                    
                    if(CallsCount<CallsList.Size()&&(PhysicianID.equals(CallsList[CallsCount].Physician_ID__c)))
                    {               
                        generator.writeFieldName(System.Label.MYBZ_Calls);
                        generator.writeStartArray();
                        firstCall=1;
                        usercallcount=0;
                        for(integer i = CallsCount; i<CallsList.Size(); i++)
                        {
                            CallsCount = i;
                            
                            //If the call count for a particular physician exceeds five, break out of the loop since only five most recent calls information needs to be passed.
                            if(usercallcount==5)
                            {
                                generator.writeEndObject();
                                generator.writeEndArray();
                                break;
                            }
                            
                            usercallcount++;
                            
                            //Check if the current call record correspond to the current call planning record
                            if(PhysicianID.equals(CallsList[i].Physician_ID__c))
                            {
                                //Check if the current record encountered corresponds to the same call as the previous.
                                if(!currentCallID.equals(CallsList[i].Call_ID__c))
                                {
                                    newCallID=1;
                                    currentCallID= CallsList[i].Call_ID__c;
                                }
                                else
                                {
                                    newCallID=0;
                                }
                                
                                
                                if( newCallID==1 && usercallcount<6)
                                {
                                    callsProductNumber = 1;
                                    if(firstCall==1)
                                    {
                                        generator.writeStartObject();
                                        firstCall=0;
                                    }
                                    else
                                    {
                                        generator.writeEndObject();
                                        generator.writeStartObject();
                                    }
                                    
                                    //Write the required JSON fields for the new call encountered.
                                    if(CallsList[i].Call_Date__c!=null)
                                        generator.writeStringField(System.Label.MYBZ_Date,CallsList[i].Call_Date__c.format(System.Label.MYBZ_DateFormat));   
                                    
                                    else
                                        
                                        generator.writeNullField(System.Label.MYBZ_Date);
                                    
                                    if(CallsList[i].Call_Type__c!=null)
                                        generator.writeStringField(System.Label.MYBZ_Type,CallsList[i].Call_Type__c);
                                    
                                    else
                                        
                                        generator.writeNullField(System.Label.MYBZ_Type);
                                    
                                }
                                else
                                {
                                    callsProductNumber+=1;
                                    
                                }
                                
                                //Information       
                                if(CallsList[i].Call_Type__c.equals(System.Label.MYBZ_SampleOnly))
                                {
                                    if(callsProductNumber==2)
                                    {
                                        usercallcount--;
                                        if(CallsList[i-1].Product__c!=NULL)
                                        {
                                            if(!CallsList[i].Product__r.Name.equals(CallsList[i-1].Product__r.Name)&&(CallsList[i].Product__c!=NULL))
                                            {
                                                generator.writeStringField(System.Label.MYBZ_Product2,CallsList[i].Product__r.Name);
                                            }
                                        }   
                                        
                                        
                                    }
                                    else
                                    {
                                        if((CallsList[i].Product__c!=NULL))
                                        {
                                            generator.writeStringField(System.Label.MYBZ_Product1,CallsList[i].Product__r.Name);
                                        }
                                    }
                                }
                                
                                
                                if((callsProductNumber<=2)&&(!CallsList[i].Call_Type__c.equals(System.Label.MYBZ_SampleOnly)))
                                {
                                    
                                    if(callsProductNumber==2)
                                    {
                                        usercallcount--;
                                        
                                        if(CallsList[i-1].Product__c!=NULL)
                                        {
                                            if(!CallsList[i].Product__r.Name.equals(CallsList[i-1].Product__r.Name)&&(CallsList[i].Product__c!=NULL)&&(CallsList[i].Product_Position__c==2))
                                            {
                                                generator.writeStringField(System.Label.MYBZ_Product2,CallsList[i].Product__r.Name);
                                            }
                                        }   
                                        
                                        
                                        
                                        
                                    }
                                    else
                                    {
                                        
                                        if((CallsList[i].Product__c!=NULL)&&CallsList[i].Product_Position__c==1)
                                        {
                                            generator.writeStringField(System.Label.MYBZ_Product1,CallsList[i].Product__r.Name);
                                        }
                                    }
                                }
                                if((i+1 == CallsList.size() )||(!PhysicianID.equals(CallsList[i+1].Physician_ID__c)))
                                {
                                    //closing all calls
                                    
                                    generator.writeEndObject();
                                    generator.writeEndArray();
                                    if((i+1)!=CallsList.size())
                                    {
                                        CallsCount+=1;
                                    }
                                    break;
                                }                       
                            } // end of if same user    
                            
                        }// end of calls for
                        
                        
                    }
                    
                } //end of if next user is different
                
                
                
            } // end of user for
            
            
            generator.writeEndObject();
            generator.writeEndArray();
            generator.writeEndObject();
            JsonString = generator.getAsString();
            JsonString=JsonString.replaceall('\n','');
            System.Debug('--CallPlanning' + JsonString);
            Object CallPlanningObject=Json.deserializeUntyped(JsonString);
            return CallPlanningObject;
        }
        catch(Exception E) 
        {
            system.debug('Exception occurred during execution of CallPlanning method' + e);
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                             Error_Message__c= e.getMessage(),
                                                             Running_User__c = UserInfo.getUserId() ,
                                                             Stack_Trace__c = e.getStackTraceString()); 
            insert errlog;
            return null ;
        }
        
    }
}