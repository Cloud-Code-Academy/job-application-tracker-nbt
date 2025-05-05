@isTest
private class TaskCreationHelperTest {

    @isTest
    static void createTasks_statusChangedFromSavedToApplying_tasksCreatedWithCorrectFields() {
        // Create a Contact
        Contact contact = new Contact(LastName = 'Test Contact');
        insert contact;

        // Insert Job Application in 'Saved' status
        Job_Application__c jobApp = new Job_Application__c(
            Name = 'Test Job App',
            Status__c = 'Saved',
            Primary_Contact__c = contact.Id,
            OwnerId = UserInfo.getUserId()
        );
        insert jobApp;

        // Delete any tasks created by trigger on insert
        delete [SELECT Id FROM Task WHERE WhatId = :jobApp.Id];

        // Manually simulate status change from 'Saved' to 'Applying'
        Job_Application__c oldJobApp = new Job_Application__c(Id = jobApp.Id, Status__c = 'Saved');
        Job_Application__c updatedJobApp = new Job_Application__c(
            Id = jobApp.Id,
            Status__c = 'Applying',
            OwnerId = jobApp.OwnerId,
            Primary_Contact__c = contact.Id
        );

        Map<Id, Job_Application__c> oldMap = new Map<Id, Job_Application__c>{ jobApp.Id => oldJobApp };
        List<Job_Application__c> updatedList = new List<Job_Application__c>{ updatedJobApp };

        Test.startTest();
        TaskCreationHelper.createTasks(updatedList, oldMap, true);
        Test.stopTest();

        // Assert 5 new tasks were created
        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :jobApp.Id];
        System.assertEquals(5, tasks.size(), 'Exactly 5 tasks should have been created during this test.');
    }
    @isTest
    static void createTasks_checkStatusChangeFalse_tasksCreatedRegardlessOfChange() {
        Contact contact = new Contact(LastName = 'No Check Contact');
        insert contact;

        Job_Application__c jobApp = new Job_Application__c(
            Name = 'Job App No Check',
            Status__c = 'Interviewing',
            Primary_Contact__c = contact.Id
        );
        insert jobApp;

        // Delete tasks created by trigger
        delete [SELECT Id FROM Task WHERE WhatId = :jobApp.Id];

        List<Job_Application__c> jobAppList = [SELECT Id, Status__c, OwnerId, Primary_Contact__c FROM Job_Application__c WHERE Id = :jobApp.Id];

        Test.startTest();
        TaskCreationHelper.createTasks(jobAppList, new Map<Id, Job_Application__c>(), false);
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :jobApp.Id];
        System.assertEquals(5, tasks.size(), 'Tasks should be created when checkStatusChange is false');
    }

    @isTest
    static void createTasks_noStatus_noTasksCreated() {
        // Create a contact to associate with the job application
        Contact contact = new Contact(LastName = 'Test Contact');
        insert contact;

        // Create a job application with no Status__c value
        Job_Application__c jobApp = new Job_Application__c(
            Name = 'No Status App',
            OwnerId = UserInfo.getUserId(),
            Primary_Contact__c = contact.Id
            // Status__c is intentionally left null
        );
        insert jobApp;

        // Trigger the helper logic manually
        Test.startTest();
        TaskCreationHelper.createTasks(
            new List<Job_Application__c>{ jobApp },
            new Map<Id, Job_Application__c>(),
            false
        );
        Test.stopTest();

        // Query for any tasks that might have been created
        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :jobApp.Id];

        // Assert that no tasks were created
        System.assertEquals(0, tasks.size(), 'No tasks should be created when Status__c is null.');
    }
}