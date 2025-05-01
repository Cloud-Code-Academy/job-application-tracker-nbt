@IsTest
public with sharing class JobApplicationSalaryTest {

    @IsTest
    static void handleSalaryAutomation_salaryAndTaxFieldsPopulateOnInsert_expectSuccess() {
        // Arrange
        List<Job_Application__c> jobAppsToInsert = TestDataFactory.createJobApplications(1);

        // Act
        Test.startTest();
        insert jobAppsToInsert;
        Test.stopTest();

        // Assert
        List<Job_Application__c> insertedJobApps = [SELECT Id, Name, Salary__c, Federal_Income_Tax__c, Social_Security_Tax__c, Medicare_Tax__c, Net_Salary__c FROM Job_Application__c WHERE Id IN :jobAppsToInsert];

        Assert.isTrue(insertedJobApps.size() > 0, 'List should not be empty');

        for (Job_Application__c jobApps : insertedJobApps) {
            if (jobApps.Salary__c == null) {
                Assert.areEqual(null, jobApps.Federal_Income_Tax__c, 'Federal Income Tax is incorrect');
                Assert.areEqual(null, jobApps.Social_Security_Tax__c, 'Social Security Tax is incorrect');
                Assert.areEqual(null, jobApps.Medicare_Tax__c, 'Medicare Tax is incorrect');
                Assert.areEqual(null, jobApps.Net_Salary__c, 'Net Salary is incorrect');
            } else if (jobApps.Salary__c == 0) {
                Assert.areEqual(0, jobApps.Federal_Income_Tax__c, 'Federal Income Tax is incorrect');
                Assert.areEqual(0, jobApps.Social_Security_Tax__c, 'Social Security Tax is incorrect');
                Assert.areEqual(0, jobApps.Medicare_Tax__c, 'Medicare Tax is incorrect');
                Assert.areEqual(0, jobApps.Net_Salary__c, 'Net Salary is incorrect');
            } else if (jobApps.Salary__c == 15000) {
                Assert.areEqual(0, jobApps.Federal_Income_Tax__c, 'Federal Income Tax is incorrect');
                Assert.areEqual(15000 * 0.062, jobApps.Social_Security_Tax__c, 'Social Security Tax is incorrect');
                Assert.areEqual(15000 * 0.0145, jobApps.Medicare_Tax__c, 'Medicare Tax is incorrect');
                Assert.areEqual(15000 - 0 - (15000 * 0.062) - (15000 * 0.0145), jobApps.Net_Salary__c, 'Net Salary is incorrect');
            } else if (jobApps.Salary__c == 40000) {
                Assert.areEqual(2761.5, jobApps.Federal_Income_Tax__c, 'Federal Income Tax is incorrect');
                Assert.areEqual(40000 * 0.062, jobApps.Social_Security_Tax__c, 'Social Security Tax is incorrect');
                Assert.areEqual(40000 * 0.0145, jobApps.Medicare_Tax__c, 'Medicare Tax is incorrect');
                Assert.areEqual(40000 - 2761.5 - (40000 * 0.062) - (40000 * 0.0145), jobApps.Net_Salary__c, 'Net Salary is incorrect');
            } else if (jobApps.Salary__c == 80000) {
                Assert.areEqual(9214.0, jobApps.Federal_Income_Tax__c, 'Federal Income Tax is incorrect');
                Assert.areEqual(80000 * 0.062, jobApps.Social_Security_Tax__c, 'Social Security Tax is incorrect');
                Assert.areEqual(80000 * 0.0145, jobApps.Medicare_Tax__c, 'Medicare Tax is incorrect');
                Assert.areEqual(80000 - 9214.0 - (80000 * 0.062) - (80000 * 0.0145), jobApps.Net_Salary__c, 'Net Salary is incorrect');
            } else if (jobApps.Salary__c == 150000) {
                Assert.areEqual(25247.0, jobApps.Federal_Income_Tax__c, 'Federal Income Tax is incorrect');
                Assert.areEqual(150000 * 0.062, jobApps.Social_Security_Tax__c, 'Social Security Tax is incorrect');
                Assert.areEqual(150000 * 0.0145, jobApps.Medicare_Tax__c, 'Medicare Tax is incorrect');
                Assert.areEqual(150000 - 25247.0 - (150000 * 0.062) - (150000 * 0.0145), jobApps.Net_Salary__c, 'Net Salary is incorrect');
            } else if (jobApps.Salary__c == 225000) {
                Assert.areEqual(44263.0, jobApps.Federal_Income_Tax__c, 'Federal Income Tax is incorrect');
                Assert.areEqual(225000 * 0.062, jobApps.Social_Security_Tax__c, 'Social Security Tax is incorrect');
                Assert.areEqual(225000 * 0.0145, jobApps.Medicare_Tax__c, 'Medicare Tax is incorrect');
                Assert.areEqual(225000 - 44263.0 - (225000 * 0.062) - (225000 * 0.0145), jobApps.Net_Salary__c, 'Net Salary is incorrect');
            } else if (jobApps.Salary__c == 500000) {
                Assert.areEqual(139297.25, jobApps.Federal_Income_Tax__c, 'Federal Income Tax is incorrect');
                Assert.areEqual(500000 * 0.062, jobApps.Social_Security_Tax__c, 'Social Security Tax is incorrect');
                Assert.areEqual(500000 * 0.0145, jobApps.Medicare_Tax__c, 'Medicare Tax is incorrect');
                Assert.areEqual(500000 - 139297.25 - (500000 * 0.062) - (500000 * 0.0145), jobApps.Net_Salary__c, 'Net Salary is incorrect');
            } else if (jobApps.Salary__c == 1000000) {
                Assert.areEqual(321470.25, jobApps.Federal_Income_Tax__c, 'Federal Income Tax is incorrect');
                Assert.areEqual(1000000 * 0.062, jobApps.Social_Security_Tax__c, 'Social Security Tax is incorrect');
                Assert.areEqual(1000000 * 0.0145, jobApps.Medicare_Tax__c, 'Medicare Tax is incorrect');
                Assert.areEqual(1000000 - 321470.25 - (1000000 * 0.062) - (1000000 * 0.0145), jobApps.Net_Salary__c, 'Net Salary is incorrect');
            }
        }
    }

    @IsTest
    static void handleSalaryAutomation_salaryAndTaxFieldsPopulateOnUpdate_expectSuccess() {
        // Arrange
        List<Job_Application__c> jobAppsToInsert = TestDataFactory.createJobApplications(1);
        insert jobAppsToInsert;

        List<Job_Application__c> jobAppsToUpdate = [SELECT Id, Salary__c FROM Job_Application__c WHERE Id IN :jobAppsToInsert];
        for (Job_Application__c jobApp : jobAppsToUpdate) {
            if (jobApp.Salary__c == null) {
                jobApp.Salary__c = 100000;
            }
            if (jobApp.Salary__c == 150000) {
                jobApp.Salary__c = 200000;
            }
        }

        // Act
        Test.startTest();
        update jobAppsToUpdate;
        Test.stopTest();

        // Assert
        List<Job_Application__c> updatedJobApps = [SELECT Id, Name, Salary__c, Federal_Income_Tax__c, Social_Security_Tax__c, Medicare_Tax__c, Net_Salary__c FROM Job_Application__c WHERE Id IN :jobAppsToUpdate];

        Assert.isTrue(updatedJobApps.size() > 0, 'List should not be empty');

        for (Job_Application__c jobApps : updatedJobApps) {
            if (jobApps.Salary__c == 100000) {
                Assert.areEqual(13614.00, jobApps.Federal_Income_Tax__c, 'Federal Income Tax is incorrect');
                Assert.areEqual(100000 * 0.062, jobApps.Social_Security_Tax__c, 'Social Security Tax is incorrect');
                Assert.areEqual(100000 * 0.0145, jobApps.Medicare_Tax__c, 'Medicare Tax is incorrect');
                Assert.areEqual(100000 - 13614.00 - (100000 * 0.062) - (100000 * 0.0145), jobApps.Net_Salary__c, 'Net Salary is incorrect');
            } else if (jobApps.Salary__c == 200000) {
                Assert.areEqual(37247.00, jobApps.Federal_Income_Tax__c, 'Federal Income Tax is incorrect');
                Assert.areEqual(200000 * 0.062, jobApps.Social_Security_Tax__c, 'Social Security Tax is incorrect');
                Assert.areEqual(200000 * 0.0145, jobApps.Medicare_Tax__c, 'Medicare Tax is incorrect');
                Assert.areEqual(200000 - 37247.00 - (200000 * 0.062) - (200000 * 0.0145), jobApps.Net_Salary__c, 'Net Salary is incorrect');
            }
        }
    }

    @IsTest
    static void handleSalaryAutomation_negativeSalaryOnInsert_expectFailure() {
        // Arrange
        Job_Application__c jobAppsToInsert = new Job_Application__c(
            Name = 'Negative Salary Test',
            Salary__c = -100000
        );

        // Act
        Test.startTest();
        Database.SaveResult result = Database.insert(jobAppsToInsert, false);
        Test.stopTest();

        // Assert
        System.assertEquals(false, result.isSuccess(), 'Insert should fail for negative salary');
    }

    @IsTest
    static void handleSalaryAutomation_negativeSalaryOnUpdate_expectFailure() {
        // Arrange
        Job_Application__c jobAppsToInsert = new Job_Application__c(
            Name = 'Negative Salary Test',
            Salary__c = 100000
        );
        insert jobAppsToInsert;

        jobAppsToInsert.Salary__c = -200000;

        // Act
        Test.startTest();
        Database.SaveResult result = Database.update(jobAppsToInsert, false);
        Test.stopTest();

        // Assert
        System.assertEquals(false, result.isSuccess(), 'Update should fail for negative salary');
    }









}