| Class Name | Description |
|------------|-------------|
| MERC_ETAccountEmailTriggerImpl.cls | Queues emails for the MERC_ETSubscriberFutureProcessor |
| MERC_ETAccountEmailTriggerImpl_Test.cls | Tests MERC_ETAccountEmailTriggerImpl |
| MERC_ET_Authorizer.cls | Authorizes against the Marketing Cloud Rest API |
| MERC_ET_Authorizer_Test.cls | Tests MERC_ET_Authorizer |
| MERC_ET_AuthorizerCallout_Mock.cls | Assists in testing the MERC_ET_Authorizer |
| MERC_ETCallControl.cls | Calls the Marketing Cloud Rest API |
| MERC_ETDataExtension.cls | Represents data extensions and their fields. This is used to share details for meeting participants |
| MERC_ETDataExtensionCallout_Mock.cls | A Mock for testing REST calls to the Marketing Cloud Rest API |
| MERC_ETDataExtensionPopulateCallout_Mock.cls | A Mock for testing REST calls to the Marketing Cloud Rest API |
| MERC_ETDataExtensionProcessor.cls | creates data extensions for email sends |
| MERC_ETDataExtensionProcessor_Test.cls | tests MERC_ETDataExtensionProcessor |
| MERC_ETFolderedEmail.cls | represents an email folder |
| MERC_ETMeetingEmailSendExtension.cls | Controller extension which provides functionality for MeetingSendEmail page. |
| MERC_ETMeetingEmailSendExtension_Test.cls | tests MERC_ETMeetingEmailSendExtension |
| MERC_ETMeetingEmailSendFutureProc_Test.cls | tests MERC_ETMeetingEmailSendFutureProcessor |
| MERC_ETMeetingEmailSendFutureProcessor.cls | Creates a et4ae5__SendDefinition__c and monitors it's progress |
| MERC_ETMeetingEmailSendTriggerImpl.cls | Defines MeetingEmailSendWrapper and queues emails for MERC_ETMeetingEmailSendFutureProcessor through handleSendDefinitionProcessForMeetingEmailSend |
| MERC_ETMeetingEmailSendTriggerImpl_Test.cls | tests MERC_ETMeetingEmailSendTriggerImpl |
| MERC_ETMeetingParticipantTrackingContExt.cls | Controller extension for displaying et4ae5__IndividualEmailResult__c for a Meeting Participant |
| MERC_ETMockHttpResponseGenerator.cls | for mocking responses during tests |
| MERC_ETNoSendClassificationException.cls | Exception for when there is no Send Classification |
| MERC_ETObject.cls | Used to represent the data contract of the Marketing Cloud REST API  |
| MERC_ETParseString.cls | A Class for parsing emails and emailFolderDetails |
| MERC_ETSendAndAuthorize_Mock.cls | mocks for the send definition callout  |
| MERC_ETSendClassification.cls | represents a Send Classification from the Marketing Cloud REST API |
| MERC_ETSendDefinition.cls | represents a Send Classification from the Marketing Cloud REST API|
| MERC_ETSendDefinitionCallout_Mock.cls | Mocks calling out for a send definition |
| MERC_ETSendDefinitionProcessor.cls | creates send definitions |
| MERC_ETSendDefinitionProcessor_Test.cls | tests MERC_ETSendDefinitionProcessor |
| MERC_ETSendEmailWrapper.cls | Used by MERC_ETMeetingEmailSendExtension to send emails through MERC_ETDataExtensionProcessor |
| MERC_ETSubscriber.cls | Represents a subscriber in Marketing Cloud API |
| MERC_ETSubscriberFutureProcessor.cls | handles Subscriber Updates as a Future callout |
| MERC_ETSubscriberProcessor.cls | handles calling the Marketing Cloud API to retreive/update Subscribers |
| MERC_ETSubscriberFutureProcessorTest.cls | Tests MERC_ETSubscriberFutureProcessor |
| MERC_ETSubscriberProcessorTest.cls | Tests MERC_ETSubscriberProcessor |
| MERC_ETSubscriberProcessorCallout_Mock.cls | Mock for MERC_ETSubscriberProcessor |
| MERC_ETSendEmailWrapper_Test.cls | tests the send email wrapper |
| MERC_ETTestUtils.cls | test utils specifically for ET |
| MERC_TestFactory.cls | test utils used by the whole org |
