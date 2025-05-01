public with sharing class JobApplicationTriggerHandler extends TriggerHandler {
    // Variables to store new and old versions of Job_Application__c records and their maps by ID.
    private List<Job_Application__c> newJobApplications;
    private Map<Id, Job_Application__c> newJobApplicationMap;
    private List<Job_Application__c> oldJobApplications;
    private Map<Id, Job_Application__c> oldJobApplicationMap;

    // Initialize the new and old record lists and maps using Trigger.new, Trigger.old, and their corresponding maps.
    public JobApplicationTriggerHandler() {
        this.newJobApplications = (List<Job_Application__c>) Trigger.new;
        this.newJobApplicationMap = (Map<Id, Job_Application__c>) Trigger.newMap;
        this.oldJobApplications = (List<Job_Application__c>) Trigger.old;
        this.oldJobApplicationMap = (Map<Id, Job_Application__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        JobApplicationSalaryHelper.calculateSalaryAndTaxOnInsert(this.newJobApplications);
        JobApplicationPrimaryContactHelper.setPrimaryContacts(this.newJobApplications);
    }
    public override void beforeUpdate() {
        JobApplicationSalaryHelper.calculateSalaryAndTaxOnUpdate(this.newJobApplications, this.oldJobApplicationMap);
        JobApplicationPrimaryContactHelper.setPrimaryContacts(this.newJobApplications);
    }
    public override void afterInsert() {    
        TaskCreationHelper.createTasks(this.newJobApplications, this.oldJobApplicationMap, false); // No need to compare old and new — just create tasks
    }
    public override void afterUpdate() {    
        TaskCreationHelper.createTasks(this.newJobApplications, this.oldJobApplicationMap, true); // Compare old and new status
    }
    public override void afterUndelete() {    
        TaskCreationHelper.createTasks(this.newJobApplications, this.oldJobApplicationMap, false); // No need to compare old and new — just create tasks
    }


}