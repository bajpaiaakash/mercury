/* Class Name  : Test_ACED_WebtrendClass
* Description  : Test Class for ACED_WebtrendClass
* Created By   : Goutham
* Created Date : 9/23/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest(SeeAllData=false)
public class Test_ACED_WebtrendClass{

    static testMethod void insertNewDeliveryActualLine() {
    
    User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
            
    System.runAs(runAsUser) {
    
    ACED_WebtrendClass WebtrendClass = New ACED_WebtrendClass();
    ACED_WebtrendClass.Dimensions Dim = New ACED_WebtrendClass.Dimensions();       
    ACED_WebtrendClass.Measures measures = New ACED_WebtrendClass.Measures();
    ACED_WebtrendClass.Definition  Def = New ACED_WebtrendClass.Definition();
    ACED_WebtrendClass.Data data = New ACED_WebtrendClass.Data();
    ACED_WebtrendClass.spaceName spaceName= New ACED_WebtrendClass.spaceName();
    ACED_WebtrendClass.language language= New ACED_WebtrendClass.language();
    ACED_WebtrendClass.SubRows SubRows = New ACED_WebtrendClass.SubRows();
    ACED_WebtrendClass.Test Testwrapper = New ACED_WebtrendClass.Test();
    ACED_WebtrendClass.Measures_Z Measures_Z = New ACED_WebtrendClass.Measures_Z();
    Test.startTest();
        try{
        string s = '[{"definition":{"accountID":20511,"profileID":"4jhqFRnGNU6","ID":"ProfileMetrics","name":"ProfileMetrics","description":"","language":null,"timezone":"UTC1","dimensions":[{"ID":"ProfileID","name":"ProfileID"}],"measures":[{"name":"PageViews","ID":"PageViews","columnID":0,"measureFormatType":null},{"name":"Visits","ID":"Visits","columnID":1,"measureFormatType":null},{"name":"Visitors","ID":"Visitors","columnID":2,"measureFormatType":null},{"name":"NewVisitors","ID":"NewVisitors","columnID":6,"measureFormatType":null},{"name":"BounceRate","ID":"BounceRate","columnID":9,"measureFormatType":"percent"},{"name":"AvgTimeonSite","ID":"AvgTimeOnSite","columnID":10,"measureFormatType":"time_seconds"},{"name":"AvgVisitorsperDay","ID":"AvgVisitorsPerDay","columnID":11,"measureFormatType":null},{"name":"PageViewsperVisit","ID":"PageViewsPerVisit","columnID":12,"measureFormatType":null},{"name":"AvgTimeonSiteperVisitor","ID":"AvgSiteTimePerVisitor","columnID":13,"measureFormatType":"time_seconds"}]},"data":[{"period":"Day","start_date":"2015-01-01","end_date":"2015-01-31","measures":[{"metricName": "PageViewsperVisit","value":"5.68"},{"metricName": "NewVisitors","value":"0"},{"metricName": "Visitors","value":"8"},{"metricName": "AvgTimeonSiteperVisitor","value":"2130.75"},{"metricName": "AvgVisitorsperDay","value":"1.76470588235294"},{"metricName": "BounceRate","value":"14"},{"metricName": "PageViews","value":"284"},{"metricName": "AvgTimeonSite","value":"415.756097560976"},{"metricName": "Visits","value":"50"}],"SubRows":{"Test":{"measures":[{"metricName": "PageViewsperVisit","value":"5.68"},{"metricName": "NewVisitors","value":"0"},{"metricName": "Visitors","value":"8"},{"metricName": "AvgTimeonSiteperVisitor","value":"2130.75"},{"metricName": "AvgVisitorsperDay","value":"1.76470588235294"},{"metricName": "BounceRate","value":"14"},{"metricName": "PageViews","value":"284"},{"metricName": "AvgTimeonSite","value":"415.756097560976"},{"metricName": "Visits","value":"50"}]}}}]}]';
        list<ACED_WebtrendClass> lResponse = ACED_WebtrendClass.parse(s);
        //Checking the size of deserialized response
        System.assertequals(lResponse.size(),1);
        }
        catch(exception e){
        }  
    Test.stopTest();
    }
}
}