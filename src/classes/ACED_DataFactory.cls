/*�Class�Name��:�ACED_DataFactory
*�Description��:�Utility�class�for�ACE Project
*�Created�By���:�Goutham
*�Created�Date�:�19-09-2014
*�Modification�Log:��
*�--------------------------------------------------------------------------------------------------------------------------------------
*�Developer����������������Date�����������������Modification�ID��������Description�
*�---------------------------------------------------------------------------------------------------------------------------------------

*/

public class ACED_DataFactory{

    //Creating User
       public static User createUser(String PermissionSetLabel){
       
        Profile pfl = [select id from profile where name='GSO Basic User_Platform'];
         //Declaring the User
        User runAsUser = new User(alias = 'Admin', email='appAdmin@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = pfl.Id,  country='United States', CommunityNickname = 'u1',
            timezonesidkey='America/Los_Angeles', username='appAdmin@gso_org.com' , ACED_HUB__c='ACE HUB' , ACED_Affiliate__c = 'ACE');
        
        Insert runAsUser;     
            
        PermissionSet pSet = [SELECT ID,Label from PermissionSet WHERE Name=:PermissionSetLabel];
        PermissionSetAssignment Asign = New PermissionSetAssignment();
        Asign.AssigneeId=runAsUser.ID;
        Asign.PermissionSetId=pSet.ID;
        Insert Asign;
        
        Return runAsUser;
        
            
                    
        }

   //Inserting Product Groups
   public static List<Product_Group_GLBL__c> createProdGroup(Integer count){
    List<Product_Group_GLBL__c> lPrdGrp  = new List<Product_Group_GLBL__c>();
        for(Integer i = 0 ; i < count ; i++){
                Product_Group_GLBL__c PrdGrp = New Product_Group_GLBL__c();
                PrdGrp.Cntry_Cd_GLBL__c='US';
                PrdGrp.Crt_Dt_GLBL__c=system.today();
                PrdGrp.Grp_Prps_Cd_GLBL__c='TEST';
                PrdGrp.Lst_Pblsh_Dt_GLBL__c=system.today();
                PrdGrp.Updt_Dt_GLBL__c=system.today();
                PrdGrp.Name='TestBrand'+i;
                PrdGrp.Dialect_Nm_GLBL__c='Test';
                lPrdGrp.add(PrdGrp);
        }
        insert lPrdGrp;
        return lPrdGrp;
    }
   
    
    //Creating Brand Indications
    public static List<ACED_Brand_Indications__c> createBrandIndication(Integer count){
    List<ACED_Brand_Indications__c> lBrnd = new List<ACED_Brand_Indications__c>();
        for(Integer i = 0 ; i < count ; i++){
                ACED_Brand_Indications__c Brnd = new ACED_Brand_Indications__c();
                Brnd.Name='Test'+i;
                Brnd.Brand__c='TestBrand'+i;                
                Brnd.Business_Unit__c='Marketing';
                Brnd.Therapeutic_Area__c='Cardio';
                lBrnd.add(Brnd);
        }
        insert lBrnd;
        return lBrnd;
    }
    //Creating Programs
    public static List<ACED_Programs__c> createProgram(Integer count){
    List<ACED_Programs__c> lProgram = new List<ACED_Programs__c>();
        for(Integer i = 0 ; i < count ; i++){
                ACED_Programs__c Program = new ACED_Programs__c();
                Program.Name='Test'+i;
                Program.Business_Function__c='Marketing';
                Program.HUB__c='ACE HUB';
                Program.Affiliate__c='ACE';
                Program.Scope__c='Global';
                Program.Year__c='2014';
                lProgram.add(Program);
        }
        insert lProgram ;
        return lProgram ;
    }
    //Creating Program Indication
    public static List<ACED_Program_Indication__c> createProgramIndication(Integer count){
    List<ACED_Program_Indication__c> lProgramInd = new List<ACED_Program_Indication__c>();
    List<ACED_Brand_Indications__c> lBrandInd  = createBrandIndication(count);
    List<ACED_Brand_Indications__c> lBrandInd2  = createBrandIndication(count);
    List<ACED_Programs__c> lPrograms  = createProgram(count);    
        for(Integer i = 0 ; i < count ; i++){
                ACED_Program_Indication__c PrgInd = new ACED_Program_Indication__c();
                PrgInd.Indication__c = lBrandInd[i].ID;
                PrgInd.Program__c = lPrograms[i].ID;
                PrgInd.Effort__c=90;
                lProgramInd.add(PrgInd);
                ACED_Program_Indication__c PrgInd2 = new ACED_Program_Indication__c();
                PrgInd2.Indication__c = lBrandInd2[i].ID;
                PrgInd2.Program__c = lPrograms[i].ID;
                PrgInd2.Effort__c=10;
                lProgramInd.add(PrgInd2);
              
        }
        insert lProgramInd;
        return lProgramInd;
    }
    
    //Inserting 
    public static List<ACED_Channel__c> createChannels(Integer count){
    List<ACED_Channel__c> lChnl = New List<ACED_Channel__c>();
        for(Integer i = 0 ; i < count ; i++){             
            ACED_Channel__c iChnl = New ACED_Channel__c();
            iChnl.Name='TestChnl'+i;
            iChnl.Channel_Category__c='Email';
            iChnl.Weight__c=1;
            lChnl.add(iChnl);
         }
        insert lChnl;
        return lChnl;
    }
        
    //Inserting Channel Attribute
    public static List<ACED_Channel_Attribute__c> createChannelAttributes(Integer count){
    List<ACED_Channel_Attribute__c> lChnlAttrib = New List<ACED_Channel_Attribute__c>(); 
    List<ACED_Channel__c> lChannels  = createChannels(count);    
    List<ACED_Deliveries__c> lDeliveries=createDeliveries(count);
        for(Integer i = 0 ; i < count ; i++){
            ACED_Channel_Attribute__c iChnlAttrib = New ACED_Channel_Attribute__c();
            iChnlAttrib.Attribute_Name__c='Sent';
            
            iChnlAttrib.Channel__c=lDeliveries[i].Activity__r.Channel__c;
            
          
            iChnlAttrib.Actual__c=true;
            lChnlAttrib.add(iChnlAttrib);
        }
        Insert lChnlAttrib;
        return lChnlAttrib;
    }
    
    
    //Inserting Channel Attributes Potential and Actual
     
    public static List<ACED_Channel_Attribute__c> createPotentialChannelAttributes(Integer count, List<ACED_Channel__c> lChannel ){
    
    List<ACED_Channel_Attribute__c> lChnlAttribPot = New List<ACED_Channel_Attribute__c>(); 
    List<ACED_Channel__c> lChannels  = createChannels(count);   
    //List<ACED_Deliveries__c> lDeliveries=createDeliveries(count);
        for(Integer i = 0 ; i < count ; i++){
                      
            ACED_Channel_Attribute__c iChnlAttribPot = New ACED_Channel_Attribute__c();
            iChnlAttribPot.Attribute_Name__c='Mailed';
            iChnlAttribPot.Channel__c = lchannels[i].Id;
            iChnlAttribPot.Potential__c=true;
            lChnlAttribPot.add(iChnlAttribPot);
            ACED_Channel_Attribute__c iChnlAttribAct = New ACED_Channel_Attribute__c();
            iChnlAttribAct.Attribute_Name__c='Sent';
            iChnlAttribAct.Channel__c = lchannels[i].Id;
            iChnlAttribAct.Potential__c=true;
            lChnlAttribPot.add(iChnlAttribAct);
        }
      
        Insert lChnlAttribPot;
        return lChnlAttribPot;
     
    }
    
    public static List<ACED_Channel_Attribute__c> createActualChannelAttributes(Integer count, List<ACED_Channel__c> lChannel ){
    
    List<ACED_Channel_Attribute__c> lChnlAttribAct = New List<ACED_Channel_Attribute__c>(); 
    List<ACED_Channel__c> lChannels  = lChannel;    
    
        for(Integer i = 0 ; i < count ; i++){                      
            ACED_Channel_Attribute__c iChnlAttribAct = New ACED_Channel_Attribute__c();
            iChnlAttribAct.Attribute_Name__c='Sent';
            iChnlAttribAct.Channel__c = lchannels[i].Id;
            iChnlAttribAct.Actual__c=true;
            lChnlAttribAct.add(iChnlAttribAct);
        }
      
        Insert lChnlAttribAct;
        return lChnlAttribAct;
     
    }
    
    //Inserting Assets
    public static List<ACED_Asset__c> createAssets(Integer count){ 
    list<ACED_Asset__c> lAssets = New list<ACED_Asset__c>();
    List<ACED_Channel__c> lChannels  = createChannels(count);
        for(Integer i = 0 ; i < count ; i++){        
            ACED_Asset__c iAst = New ACED_Asset__c();
            iAst.Name='TestAst';
            iAst.Channel__c=lChannels[i].id;
            iAst.Business_Function__c='Marketing';
            iAst.Status__c='Live';
            iAst.alive_since__c = system.today();
            iAst.HUB__c='ACE HUB';
            iAst.Affiliate__c='ACE';
            iAst.Activity_Actual_Cost__c =100;
            lAssets.add(iAst);
         }
        Insert lAssets;
        return lAssets;
    }
    //Inserting Asset Brand Indication
    public static List<ACED_Asset_Indication__c> createAssetIndications(Integer count){  
    list<ACED_Asset_Indication__c> lAssetInd = New list <ACED_Asset_Indication__c>();
    List<ACED_Asset__c> lAssets =createAssets(count);  
    List<ACED_Brand_Indications__c  > lBrands = createBrandIndication(count);      
    
        for(Integer i = 0 ; i < count ; i++){
        ACED_Asset_Indication__c AssetInd = New ACED_Asset_Indication__c();
        AssetInd.Asset__c= lAssets[i].id;
        AssetInd.Brand_Indication__c=lBrands[i].id;
        AssetInd.Effort__c=30;
        lAssetInd.add(AssetInd);
        }
        Insert lAssetInd;
        return lAssetInd;
    }
    
    //Inserting Asset Actual 
    /* public static List<ACED_Asset_Actual__c> createAssetActuals(Integer count){  
    list<ACED_Asset_Actual__c> lAssetAct = New list <ACED_Asset_Actual__c>();
    List<ACED_Asset__c> lAssets=createAssets(count);    
        for(Integer i = 0 ; i < count ; i++){
        ACED_Asset_Actual__c AssetAct = New ACED_Asset_Actual__c();
        AssetAct.Asset__c= lAssets[i].id;
        AssetAct.Month__c='March';
        lAssetAct.add(AssetAct);
        }
        Insert lAssetAct;
        return lAssetAct;
    }*/
    //Inserting Asset Actual with Asset Indications 
    public static List<ACED_Asset_Indication__c> createAssetActualsWithInd(Integer count){  
    list<ACED_Asset_Actual__c> lAssetAct = New list <ACED_Asset_Actual__c>();
    list<ACED_Asset_Indication__c > lAssetInd = New list <ACED_Asset_Indication__c>();    
    List<ACED_Asset__c> lAssets = createAssets(count);
    List<ACED_Brand_Indications__c> lBrands = createBrandIndication(count);      
       
        for(Integer i = 0 ; i < count ; i++){
        ACED_Asset_Indication__c AssetInd = New ACED_Asset_Indication__c();       
        AssetInd.Asset__c= lAssets[i].id;
        AssetInd.Brand_Indication__c=lBrands[i].id;
        AssetInd.Effort__c=30;
        lAssetInd.add(AssetInd);
        }
        Insert lAssetInd;
        
        for(Integer i = 0 ; i < count ; i++){
        ACED_Asset_Actual__c AssetAct = New ACED_Asset_Actual__c();        
        AssetAct.Asset__c= lAssets[i].id;
        AssetAct.Month__c='March';
        AssetAct.Value__c=10;
        lAssetAct.add(AssetAct);
        }
        Insert lAssetAct;
        return lAssetInd;
    }
    

    //Inserting Activities  
    public static List<ACED_Activity__c> createActivities(Integer count){
    List<ACED_Activity__c> lActivities = New List<ACED_Activity__c>();
    List<ACED_Programs__c> lProgram = createProgram(count);
    List<ACED_Program_Indication__c> lProgramInd=createProgramIndication(count);
    List<ACED_Asset__c> lAssets=createAssets(count);
        for(Integer i = 0 ; i < count ; i++){
            ACED_Activity__c Act = New ACED_Activity__c();
            //This is to avoid the validation of "program should have atleast one indiication before associating the Ativity
            Act.Program__c=lProgramInd[i].Program__c;
            Act.Planned_Start_Date__c=system.today();
            Act.Planned_End_Date__c=system.today()+1;
            Act.Assets__c=lAssets[i].ID;
            lActivities .add(Act);
         }
        
        Insert lActivities;
        return lActivities;
    }

//Inserting Activities  withoput Assets
    public static List<ACED_Activity__c> createActivitiesWithOutAssets(Integer count){
    List<ACED_Activity__c> lActivities = New List<ACED_Activity__c>();
    List<ACED_Programs__c> lProgram = createProgram(count);
    List<ACED_Program_Indication__c> lProgramInd=createProgramIndication(count);
    List<ACED_Channel__c> lChannels  = createChannels(count);
        for(Integer i = 0 ; i < count ; i++){
            ACED_Activity__c Act = New ACED_Activity__c();
            //This is to avoid the validation of "program should have atleast one indiication before associating the Ativity
            Act.Program__c=lProgramInd[i].Program__c;
            Act.Channel__c=lChannels[i].id;
            Act.Planned_Start_Date__c=system.today();
            Act.Planned_End_Date__c=system.today()+1;
            lActivities .add(Act);
         }
        
        Insert lActivities;
        return lActivities;
    }
    
    //Inserting Providers
    public static List<ACED_Providers__c> createProviders(Integer count){    
    list<ACED_Providers__c> lProviders = New list<ACED_Providers__c>();       
        for(Integer i = 0 ; i < count ; i++){
            ACED_Providers__c Provider = New ACED_Providers__c();
            Provider.Name = 'TestProvider'+i;
            Provider.HUB__c= 'ACE HUB';
            Provider.Affilliate__c= 'ACE';
            lProviders.add(Provider);
        }        
        Insert lProviders;
        return lProviders;
    }
    
    //Inserting Deliveries
    public static List<ACED_Deliveries__c> createDeliveries(Integer count){    
    List<ACED_Deliveries__c> lDeliveries = New list<ACED_Deliveries__c>();
    List<ACED_Activity__c> lActivities=createActivities(count);
    List<ACED_Providers__c> lProviders=createProviders(count); 
        for(Integer i = 0 ; i < count ; i++){
            ACED_Deliveries__c Del= New ACED_Deliveries__c();
            Del.Activity__c=lActivities[i].ID;
            Del.Provider__c=lProviders[i].ID;
            Del.Start_Date__c=System.today();
            Del.End_Date__c=System.today()+45;
            Del.PIM_Segment__c='Traditionalist';
            lDeliveries.add(Del);
        }    
        Insert lDeliveries;
        return lDeliveries;
    }
        
    //Inserting Delivery Indication
    public static List<ACED_Delivery_Indication__c> createDeliveryIndications(Integer count){
    List<ACED_Delivery_Indication__c> lDeliveryIndications = New list<ACED_Delivery_Indication__c>();
    List<ACED_Brand_Indications__c> lBrandIndiacations=createBrandIndication(count);
    List<ACED_Deliveries__c> lDeliveries =createDeliveries(count);    
        for(Integer i = 0 ; i < count ; i++){
            ACED_Delivery_Indication__c DelInd = New ACED_Delivery_Indication__c();
            DelInd.Brand_Indication__c=lBrandIndiacations[i].id;      
            DelInd.Delivery__c=lDeliveries[i].id;
            DelInd.Effort__c= 70;
            lDeliveryIndications.add(DelInd);
        }
        Insert lDeliveryIndications;
        return lDeliveryIndications;
    }
    //Inserting Delivery Actual
    public static List<ACED_Delivery_Actuals__c> createDeliveryActuals(Integer count){
    list<ACED_Delivery_Actuals__c> lDelAct = New list<ACED_Delivery_Actuals__c>();
    List<ACED_Deliveries__c> lDeliveries =createDeliveries(count);    
        for(Integer i = 0 ; i < count ; i++){
            ACED_Delivery_Actuals__c DelAct = New ACED_Delivery_Actuals__c();
            DelAct.Delivery__c=lDeliveries[i].Id;       
            lDelAct.add(DelAct);
         }
        Insert lDelAct;
        return lDelAct;
    }
    
    //Inserting Delivery Actual Indications
   /* public static List<ACED_Delivery_Indication_Actuals__c> createDeliveryIndicationActuals(Integer count){  
    list<ACED_Delivery_Indication_Actuals__c> lDelActInd = New list <ACED_Delivery_Indication_Actuals__c>();
    List<ACED_Delivery_Indication__c> lDeliveryIndications=createDeliveryIndications(count);    
        for(Integer i = 0 ; i < count ; i++){
        ACED_Delivery_Indication_Actuals__c DelActInd = New ACED_Delivery_Indication_Actuals__c();
        DelActInd.Delivery_Indication__c = lDeliveryIndications[i].id;
        DelActInd.Actual_Value__c = 500;
        DelActInd.Effort_Value__c = 100;
        lDelActInd.add(DelActInd);
        }
        Insert lDelActInd;
        return lDelActInd;
    }  */
    
    
    //Inserting Delivery Actual Indications for delivery and insert actuals
    public static List<ACED_Delivery_Indication_Actuals__c> createDeliveryIndicationActualswithActuals(Integer count){  
    List<ACED_Delivery_Indication__c> lDeliveryIndications = createDeliveryIndications(count);   
    List<ACED_Delivery_Indication_Actuals__c> lDelActInd = New List<ACED_Delivery_Indication_Actuals__c>();   
        for(Integer i = 0 ; i < count ; i++){
        ACED_Delivery_Indication_Actuals__c DelActInd = New ACED_Delivery_Indication_Actuals__c();
        DelActInd.Delivery_Indication__c = lDeliveryIndications[i].id;
        DelActInd.Actual_Value__c = 500;
        DelActInd.Effort_Value__c = 100;
        lDelActInd.add(DelActInd);
        }
        Insert lDelActInd;
        
        list<ID> lDelivery = New list<ID>();
        list<ACED_Delivery_Actuals__c> lDelAct = New list<ACED_Delivery_Actuals__c>(); 
               
        for(ACED_Delivery_Indication_Actuals__c  DelIndAct: [SELECT id,Delivery_Indication__r.Delivery__c from ACED_Delivery_Indication_Actuals__c  
                                                             WHERE id in :lDelActInd   ]){
        ACED_Delivery_Actuals__c DelAct = New ACED_Delivery_Actuals__c();                                                     
        DelAct.Delivery__c = DelIndAct.Delivery_Indication__r.Delivery__c;
        lDelivery.add(DelIndAct.Delivery_Indication__r.Delivery__c);
        lDelAct.add(DelAct);
        }
        Insert lDelAct;
        
        list<ACED_Audience__c> lAud = createAudience(1);
        
        list<ACED_Deliveries__c> lDel = New list<ACED_Deliveries__c>();
        for(ACED_Deliveries__c Del: [SELECT id,Audience__c from ACED_Deliveries__c 
                                     WHERE id in :lDelivery]){
        Del.Audience__c  = lAud[0].Id;
        lDel.add(Del);
        }
        Update lDel;
        

        return lDelActInd;
    }      
    
    
    //Inserting Delivery Actual lines
    public static List<ACED_Delivery_Actual_Line__c> createDeliveryActualLines(Integer count){  
    List<ACED_Delivery_Actual_Line__c> lDeliveryActLines = New List<ACED_Delivery_Actual_Line__c>();   
    List<ACED_Delivery_Actuals__c> lDelAct = createDeliveryActuals(count);   
        for(Integer i = 0 ; i < count ; i++){
        ACED_Delivery_Actual_Line__c DelAct = New ACED_Delivery_Actual_Line__c();
        DelAct.Delivery_Actuals__c= lDelAct[i].id;
        DelAct.Value__c=30;        
        lDeliveryActLines.add(DelAct);
        }
        Insert lDeliveryActLines;
        return lDeliveryActLines;
    }    
        
        
    //Creating Costs
    /*public static List<ACED_Cost__c> creatCosts(Integer count){
    
    List<ACED_Activity__c> lActivities=createActivities(count);
    list<ACED_Cost__c> lcosts = New list<ACED_Cost__c>();
    for(Integer i = 0 ; i < count ; i++){
        ACED_Cost__c cost=New ACED_Cost__c();
        cost.Assest_Activity__c=lActivities[i].id;
        cost.Cost__c= 5000+i;
        cost.Description__c='test cost';
        lcosts.add(cost);
        }
        insert lcosts;
        return lcosts;
    }*/
    
    
    public static List<ACED_MOT__c> creatMOTs(Integer count){   
    list<ACED_MOT__c> lMOTs = New list<ACED_MOT__c>();
    for(Integer i = 0 ; i < count ; i++){
        ACED_MOT__c newMOT=New ACED_MOT__c();        
        newMOT.Name='test MOT'+i;
        lMOTs.add(newMOT);
        }
        insert lMOTs;
        return lMOTs;
    }
    
    public static List<ACED_KPO__c> creatKPOs(Integer count){   
    list<ACED_KPO__c> lKPOs = New list<ACED_KPO__c>();
    List<ACED_Brand_Indications__c> lBrandIndications=createBrandIndication(count);
    list<ACED_MOT__c> lMOTs = creatMOTs(count);
    for(Integer i = 0 ; i < count ; i++){
        ACED_KPO__c newKPO=New ACED_KPO__c();        
        newKPO.Name='test KPO'+i;
        newKPO.Brand_Indication__c=lBrandIndications[i].id;
        newKPO.MOT__c= lMOTs[i].id;
        newKPO.Player__c='test';
        lKPOs.add(newKPO);
        }
        insert lKPOs;
        return lKPOs;
    }
    public static List<ACED_KPO_Metric__c> creatKPOMetrics(Integer count){   
    list<ACED_KPO_Metric__c> lKPOMetrics = New list<ACED_KPO_Metric__c>();
    list<ACED_KPO__c> lKPOs = creatKPOs(count);
    List<ACED_Activity__c> lActivities=createActivities(count);
    for(Integer i = 0 ; i < count ; i++){
        ACED_KPO_Metric__c newKPOMetric=New ACED_KPO_Metric__c();        
        newKPOMetric.Asset_Activity__c=lActivities[i].id;
        newKPOMetric.KPO__c= lKPOs[i].id;
        newKPOMetric.Baseline_Value__c='1';
        newKPOMetric.Goal__c='2';
        lKPOMetrics.add(newKPOMetric);
        }
        insert lKPOMetrics;
        return lKPOMetrics;
    }
    
    //Inserting Audience  
    public static List<ACED_Audience__c> createAudience(Integer count){
    List<ACED_Audience__c> lAudience = New List<ACED_Audience__c>(); 
        for(Integer i = 0 ; i < count ; i++){
            ACED_Audience__c Audi = New ACED_Audience__c();
            Audi.Name='TestAudience'+i;
            Audi.Audience_Type__c='HCP';
            Audi.Business_Function__c='Marketing';
            Audi.Professional_Type__c='Nurse';
            Audi.Specialty__c='GP';
            lAudience.add(Audi);
         }
        Insert lAudience;
        return lAudience;
    }
}