@isTest(seealldata=true)
Public class Test_MobileQRCodeExtension {
    public static testmethod void MobileQRCodeExtension(){
        MICO_Project__c p = new MICO_Project__c();
        p.Name = 'PR1';
        insert p;
        
        MICO_User_Story__c req = new MICO_User_Story__c();
        req.Project__c = p.Id;
        insert req;
        
        ApexPages.StandardController std = new ApexPages.StandardController(req);
        PageReference pageRef = Page.MobileQRcode; 
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', req.Id);
        MobileQRCodeExtension mobile = new MobileQRCodeExtension(std);
        
        Test.startTest();
        Mobile.iCode = Label.QR_Cards_Password;
        Mobile.Save();
        Mobile.req.Development_Stage__c = '10. UAT - Awaiting testing';
        Mobile.Save();
        Test.stopTest();
    }
    
    public static testmethod void MobileQRCodeExtensionWrongPass() {
        MICO_Project__c p = new MICO_Project__c();
        p.Name = 'PR2';
        insert p;
        
        User u = new user();
        u.LastName = 'blblb';
        u.Alias = 'blblb';
        u.Email = 'blblb@tesT.com';
        u.Username = 'blblb@tesT.com';
        u.CommunityNickname = 'dsfsdff';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].id;
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'en_GB';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        System.RunAs(u) {
        
            MICO_User_Story__c req = new MICO_User_Story__c();
            req.Project__c = p.Id;
            req.Compliance_Criteria__c = 'AAAA';
            req.Development_Stage__c = '5.4 Sprint Team - In Development';
            req.Supporting_BA__c = u.Id;
            req.User__c = u.Id;
            insert req;
            
            ApexPages.StandardController std = new ApexPages.StandardController(req);
            PageReference pageRef = Page.MobileQRcode;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', req.Id);
            MobileQRCodeExtension mobileWrong = new MobileQRCodeExtension(std);
            
            Test.startTest();
            mobileWrong.iCode = Label.QR_Cards_Password;
            mobileWrong.save();
            mobileWrong.req.Compliance_Criteria__c = 'dsff';
            mobileWrong.req.Development_Stage__c = '7. Sprint - Awaiting SAT';
            
            mobileWrong.save();
            Test.stopTest();
        }
    } 
}