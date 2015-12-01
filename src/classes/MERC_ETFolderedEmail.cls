public with sharing class MERC_ETFolderedEmail implements Comparable
{
    public string id { get; set; }
    public string name { get; set; }
    public string title { get; set; }
    public string encName { get; set; }
    public string encTitle { get; set; }
 
    //constructor required for comparable interface implementation - no code inside required
    public MERC_ETFolderedEmail(){ 
 
    }
  //compareTo implementation  
   public integer compareTo(Object compareTo){
    try
    {
        return name.toUpperCase().compareTo(((MERC_ETFolderedEmail) compareTo).name.toUpperCase());
    }
    catch (exception e)
    {
        return 0;
    }
   }
}