@IsTest
public with sharing class InterviewEmailReminderTest {
    
    @IsTest
    static void handleEmailReminder_testInterviewEmailReminderSchedulable_expectSuccess() {
        // Arrange
        List<Event> interviews = TestDataFactory.createEvents(1);
        insert interviews;

        Integer emailsSent = Limits.getEmailInvocations();

        // Act
        Test.startTest();
        new InterviewEmailReminderHelper().sendEmailReminder();
        Test.stopTest();

        // Assert
        System.assertEquals(emailsSent + 1, Limits.getEmailInvocations(), '1 email should have been sent');

    }

}