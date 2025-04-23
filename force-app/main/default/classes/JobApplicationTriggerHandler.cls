public with sharing class JobApplicationTriggerHandler extends TriggerHandler {
    private List<Job_Application__c> newJobApplications;
    private Map<Id, Job_Application__c> newJobApplicationMap;
    private List<Job_Application__c> oldJobApplications;
    private Map<Id, Job_Application__c> oldJobApplicationMap;

    public JobApplicationTriggerHandler() {
        this.newJobApplications = (List<Job_Application__c>) Trigger.new;
        this.newJobApplicationMap = (Map<Id, Job_Application__c>) Trigger.newMap;
        this.oldJobApplications = (List<Job_Application__c>) Trigger.old;
        this.oldJobApplicationMap = (Map<Id, Job_Application__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        JobApplicationSalaryHelper.calculateSalaryAndTaxOnInsert(this.newJobApplications);
    }
    public override void beforeUpdate() {
        JobApplicationSalaryHelper.calculateSalaryAndTaxOnUpdate(this.newJobApplications, this.oldJobApplicationMap);
    }
}