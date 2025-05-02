@IsTest
public with sharing class StaleJobsTest {
    
    @IsTest
    static void handleStaleJobsCleanup_changeStatusToClosedOnOldJobApps_expectSuccess() {
        // Arrange
        List<Job_Application__c> jobApps = TestDataFactory.createJobApplications(1);
        insert jobApps;

        // Act
        Test.startTest();
        StaleJobsHelper.cleanupStaleJobApplications();
        Test.stopTest();

        // Assert
        List<Job_Application__c> updatedJobs = [SELECT Name, Status__c, Notes__c FROM Job_Application__c WHERE Id IN :jobApps];

        Assert.isTrue(updatedJobs.size() > 0, 'List should not be empty');

        for (Job_Application__c closedJobs : updatedJobs) {
            if (closedJobs.Name.contains('Stale')) {
                Assert.areEqual('Closed', closedJobs.Status__c, 'Stale jobs did not close');
                Assert.isTrue(closedJobs.Notes__c != null && closedJobs.Notes__c.contains('Job Application was closed by an automated process'), 'Notes field should be populated');
            }
        }
    }

    @IsTest
    static void handleStaleJobsCleanup_noStatusChangeForFreshJobApps_expectNoChange() {
        // Arrange
        List<Job_Application__c> jobApps = TestDataFactory.createJobApplications(1);
        insert jobApps;

        // Act
        Test.startTest();
        StaleJobsHelper.cleanupStaleJobApplications();
        Test.stopTest();

        // Assert
        List<Job_Application__c> updatedJobs = [SELECT Name, Status__c, Notes__c FROM Job_Application__c WHERE Id IN :jobApps];

        Assert.isTrue(updatedJobs.size() > 0, 'List should not be empty');

        for (Job_Application__c closedJobs : updatedJobs) {
            if (closedJobs.Name.contains('Fresh')) {
                Assert.areNotEqual('Closed', closedJobs.Status__c, 'Fresh jobs should not have been changed');
            }
        }
    }

    @IsTest
    static void handleStaleJobsCleanup_changeStatusToClosedAndKeepExistingNotesOnOldJobApps_expectSuccess() {
        // Arrange
        List<Job_Application__c> jobApps = TestDataFactory.createJobApplications(1);
        insert jobApps;

        // Act
        Test.startTest();
        StaleJobsHelper.cleanupStaleJobApplications();
        Test.stopTest();

        // Assert
        List<Job_Application__c> updatedJobs = [SELECT Name, Status__c, Notes__c FROM Job_Application__c WHERE Id IN :jobApps];

        Assert.isTrue(updatedJobs.size() > 0, 'List should not be empty');

        for (Job_Application__c closedJobs : updatedJobs) {
            if (closedJobs.Name.contains('Stale') && closedJobs.Name.contains('Existing Notes')) {
                Assert.isTrue(closedJobs.Notes__c != null && closedJobs.Notes__c.contains('These notes better still be here after I get updated') && closedJobs.Notes__c.contains('Job Application was closed by an automated process'), 'Notes field should be populated');
            }
        }
    }

}