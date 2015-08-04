/**
 * Constants class for the forms application
 */
public with sharing class FORM_Constants {

    //Approval Status Options
    public static final String APPROVAL_STATUS = 'Approved';
    public static final String APPROVAL_STATUS_CANCELLED = 'Cancelled';
    public static final String APPROVAL_STATUS_COMPLETE = 'Complete';
    public static final String APPROVAL_STATUS_IN_PROGRESS = 'In Progress';
    public static final String APPROVAL_STATUS_NOT_APPROVED = 'Not Approved';
    
    // question types
    public static final String QUESTION_TYPE_PICKLIST = 'Picklist';
    public static final String QUESTION_TYPE_TEXT = 'Free Text';
    public static final String QUESTION_TYPE_NUMBER = 'Number';
    public static final String QUESTION_TYPE_CURRENCY = 'Currency';
    
    // default answer option text
    public static final String ANSWER_OPTION_DEFAULT_TEXT = Label.FORM_Execution_Picklist_Default;
    
    // profiles
    private static final String USER_PROFILE_GSO_BASIC_PLATFORM = 'GSO Basic User_Platform';
    private static final String USER_PROFILE_GSO_BASIC_SALESFORCE = 'GSO Basic User_Salesforce';
    
    // permission sets
    private static final String USER_PERMISSIONSET_FORM_CREATOR = 'FORM_Form_Creator';
    private static final String USER_PERMISSIONSET_FORM_EXECUTOR = 'FORM_Form_Executor';

}