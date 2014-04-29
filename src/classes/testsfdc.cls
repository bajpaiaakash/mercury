public with sharing class testsfdc extends GLBL_BaseEditController{

public Account acc { get; set; } 
private ApexPages.StandardController controller; 

public testsfdc(ApexPages.StandardController c) { 
super(c, Account.SobjectType); 
this.controller = c; 
this.acc = (Account)this.controller.getRecord(); 
} 

}