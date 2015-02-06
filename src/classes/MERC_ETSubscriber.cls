public with sharing class MERC_ETSubscriber {

    public String SubscriberKey {get;set;}
    public String LLYSubscriberKey {get;set;}
    public String EmailAddress {get;set;}
    public String SubscriberType {get;set;}

    public MERC_ETSubscriber() {
        this.SubscriberKey = 'testKey';
        this.LLYSubscriberKey = 'testLLYKey';
        this.EmailAddress = 'testEmail';
        this.SubscriberType = 'testSubType';
    }

    public MERC_ETSubscriber(String subKey, String LLYkey, String email, String subType) {
    	this.SubscriberKey = subKey;
    	this.LLYSubscriberKey = LLYkey;
    	this.EmailAddress = email;
    	this.SubscriberType = subType;
    }

}