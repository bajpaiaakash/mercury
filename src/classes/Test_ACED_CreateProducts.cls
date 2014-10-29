/* Class Name  : Test_ACED_CreateProducts 
* Description  : Test Class for ACED_CreateProducts 
* Created By   : Goutham
* Created Date : 9/22/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/
@isTest(SeeAllData=false)

//test class for ACED_CreateProducts
public class Test_ACED_CreateProducts {

    //test method for ACED_CreateProducts
    static testMethod void createNewProduct() {
    
        //Declaring the user with Digital dashboard owner Permission set   
            User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
                
        System.runAs(runAsUser) {
        
            Test.startTest();
                        
            //Inserting a list of Brandindications 
            List<ACED_Brand_Indications__c> lBrandIndications = ACED_DataFactory.createBrandIndication(1);
            
            //Inserting a  Products group 
            List<Product_Group_GLBL__c> lPrdGrp = ACED_DataFactory.createProdGroup(1);
                     
            //Creating brand indication and calling methods on VF page
            ApexPages.StandardController cnt = new ApexPages.StandardController(lBrandIndications[0]);
            ACED_CreateProducts  createProduct = New ACED_CreateProducts(cnt);
            createProduct.sProductSearch = lPrdGrp[0].Name;
            createProduct.CreateProductButton();
            createProduct.SearchProductcatalog();
            createProduct.ClearGSOLink();
            createProduct.oCreateBrandIndication = NULL;
            createProduct.CreateProductButton();           
            

            
            //System assert to check whether Product group ID is populated on Brand indication
            system.assertequals(lBrandIndications[0].PRODUCT_GROUP_ID_GLBL__c,lPrdGrp[0].Product_Group_Id_GLBL__c); 
            
            Test.stopTest();
            
            
            
            }
      }
    
    
    
}