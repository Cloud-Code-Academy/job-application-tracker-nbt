@IsTest
public with sharing class InterviewEmailReminderTest {

    @IsTest
    static void handleEmailReminder_testSchedulable_expectSuccess() {
        // Arrange
            // No data to arrange
        
        // Act
        Test.startTest();
        String sch = '0 0 7 * * ?';
        String jobId = System.schedule('Interview Email Reminder Test', sch, new InterviewEmailReminderSchedulable());
        Test.stopTest();
        
        // Assert
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

        System.assertEquals(sch, ct.CronExpression, 'Cron Expression should match');
        System.assertEquals(0, ct.TimesTriggered, 'Cron Expression should not have triggered');
    }
    
    @IsTest
    static void handleEmailReminder_testInterviewEmailReminderHelper_expectSuccess() {
        // Arrange
        List<Account> testCompanies = TestDataFactory.createAccounts(1);
        insert testCompanies;

        List<Event> interviews = TestDataFactory.createEvents(1, testCompanies);
        insert interviews;

        List<EmailMessage> emailMessagesBefore = [SELECT Id FROM EmailMessage WHERE Subject LIKE '%Interview%'];
        Assert.areEqual(0, emailMessagesBefore.size());

        // Act
        Test.startTest();
        new InterviewEmailReminderHelper().sendEmailReminder();
        Test.stopTest();

        // Assert
        List<EmailMessage> emailMessagesAfter = [SELECT Id, Status, Subject, TextBody FROM EmailMessage WHERE Subject LIKE '%Interview%'];

        Assert.areEqual(1, emailMessagesAfter.size());

        // EmailMessage Status of '3' means 'Sent'
        for (EmailMessage email : emailMessagesAfter) {
            Assert.areEqual('3', email.Status);
            Assert.isTrue(email.TextBody.contains('This is a reminder that you have an upcoming interview scheduled for tomorrow.'), 'EmailMessage should have a TextBody');
        }
    }

    @IsTest
    static void handleEmailReminder_testInterviewEmailReminderHelper_expectNoEmailsSent() {
        // Arrange
            // No interviews created for tomorrow

        List<EmailMessage> emailMessagesBefore = [SELECT Id FROM EmailMessage WHERE Subject LIKE '%Interview%'];
        Assert.areEqual(0, emailMessagesBefore.size());

        // Act
        Test.startTest();
        new InterviewEmailReminderHelper().sendEmailReminder();
        Test.stopTest();

        // Assert
        List<EmailMessage> emailMessagesAfter = [SELECT Id, Status, Subject FROM EmailMessage WHERE Subject LIKE '%Interview%'];
        Assert.areEqual(0, emailMessagesAfter.size());
    }

}