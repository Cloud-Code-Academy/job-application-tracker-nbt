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
        setPrimaryContacts(this.newJobApplications);
    }
    public override void beforeUpdate() {
        JobApplicationSalaryHelper.calculateSalaryAndTaxOnUpdate(this.newJobApplications, this.oldJobApplicationMap);
        setPrimaryContacts(this.newJobApplications);
    }
    public override void afterInsert() {    
        createTasks(false); // No need to compare old and new — just create tasks
    }
    public override void afterUpdate() {    
        createTasks(true); // Compare old and new status
    }
    public override void afterUndelete() {    
        createTasks(false); // No need to compare old and new — just create tasks
    }

public void createTasks(Boolean checkStatusChange) {
    List<Job_Application__c> jobApplicationsList = new List<Job_Application__c>();
    List<Task> tasksToInsert = new List<Task>();

    // Loop through the job applications and add them to a task creation list.  For those with no old Triggers, no need to check if status changed.
    for (Job_Application__c jobApp : newJobApplications) {
        if (checkStatusChange) {
            Job_Application__c oldJobApp = oldJobApplicationMap.get(jobApp.Id);
            if (oldJobApp.Status__c != jobApp.Status__c) {
            jobApplicationsList.add(jobApp);
            }
        } else {
            jobApplicationsList.add(jobApp);
        }
    }
    // If the list is Of job applications is not empty then Create tasks
    if(!jobApplicationsList.isEmpty()) {
        tasksToInsert = createTasksForStatus(jobApplicationsList);
    }

    // Insert tasks if applicable
    if (!tasksToInsert.isEmpty()) {
        insert tasksToInsert;
    }

}

// Method to create tasks based on job application status
public List<Task> createTasksForStatus(List<Job_Application__c> jobAppList) {
    List<Task> tasks = new List<Task>();
    Date dueDate = Date.today().addDays(1); // Default due date = tomorrow

    // Map to show the status and the list of tasks to be created for each status
    Map<String, List<String>> taskMap = new Map<String, List<String>> {
        'Saved' => new List<String>{
            'Check if the job description aligns with your interests and values',
            'Review the highlighted skills to see if the role is a good fit',
            'Research the company or role and mark your excitement level'
        },
        'Applying' => new List<String>{
            'Find and research someone who works at the company and add them as a contact',
            'Set up an informational interview to learn more about the role/company',
            'Identify potential referrals to help get your application on the top of the pile',
            'Customize your work achievements using the job description keywords',
            'Submit your application on the company website if possible'
        },
        'Applied' => new List<String>{
            'Reach out to the hiring manager or recruiter',
            'Follow up on your application via email weekly',
            'Continue identifying and saving similar job opportunities',
            'Set up weekly networking calls to explore similar companies/roles'
        },
        'Interviewing' => new List<String>{
            'Prepare your blurb or “tell me about yourself” response',
            'Practice answering behavioral interview questions',
            'Research the company and your interviewers',
            'Set up your virtual interview space and test your tech',
            'Send thank you emails within 24 hours'
        },
        'Negotiating' => new List<String>{
            'Research your market value and know your numbers',
            'Prepare your negotiation scripts',
            'Evaluate your offer and decline or accept'
        },
        'Accepted' => new List<String>{
            'Plan your resignation if applicable',
            'Take some time to relax and recharge',
            'Prepare for your first day of onboarding'
        },
        'Closed' => new List<String>{
            'Send a follow-up email thanking the interviewer and asking for feedback',
            'Review your notes and reflect on areas of improvement'
        }
    };

    // Create new task records
    for (Job_Application__c jobApp : jobAppList) {
        List<String> subjects = taskMap.get(jobApp.Status__c);

        if (subjects != null) {
            for (String subject : subjects) {
                tasks.add(new Task(
                    Subject = subject,
                    Priority = 'Normal',
                    Status = 'Not Started',
                    ActivityDate = dueDate,
                    WhatId = jobApp.Id,
                    WhoId = jobApp.Primary_Contact__c
                ));
            }
        }
    }
    
    return tasks;
}

private void setPrimaryContacts(List<Job_Application__c> jobApps) {
    Set<Id> jobAppIds = new Set<Id>();
    Set<Id> accountIds = new Set<Id>();
    
    for (Job_Application__c ja : jobApps) {
        if (ja.Primary_Contact__c == null) {
            jobAppIds.add(ja.Id);
            if (ja.Company_Account__c != null) {
                accountIds.add(ja.Company_Account__c);
            }
        }
    }
    
    if (jobAppIds.isEmpty()) return;
    
    // Query related Job Application Contacts
    Map<Id, List<Contact>> jobAppContactsMap = new Map<Id, List<Contact>>();
    for (Job_Application_Contact__c jac : [
        SELECT Job_Application__c, Contact__r.Id
        FROM Job_Application_Contact__c
        WHERE Job_Application__c IN :jobAppIds
        ORDER BY CreatedDate ASC
    ]) {
        if (!jobAppContactsMap.containsKey(jac.Job_Application__c)) {
            jobAppContactsMap.put(jac.Job_Application__c, new List<Contact>());
        }
        jobAppContactsMap.get(jac.Job_Application__c).add(jac.Contact__r);
    }
    
    // Query Account Contacts
    Map<Id, List<Contact>> accountContactsMap = new Map<Id, List<Contact>>();
    if (!accountIds.isEmpty()) {
        for (Contact c : [
            SELECT Id, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds
            ORDER BY CreatedDate ASC
        ]) {
            if (!accountContactsMap.containsKey(c.AccountId)) {
                accountContactsMap.put(c.AccountId, new List<Contact>());
            }
            accountContactsMap.get(c.AccountId).add(c);
        }
    }
    
    // Set Primary Contact
    for (Job_Application__c ja : jobApps) {
        if (ja.Primary_Contact__c == null) {
            if (jobAppContactsMap.containsKey(ja.Id) && !jobAppContactsMap.get(ja.Id).isEmpty()) {
                ja.Primary_Contact__c = jobAppContactsMap.get(ja.Id).get(0).Id;
            }
            else if (ja.Company_Account__c != null &&
                     accountContactsMap.containsKey(ja.Company_Account__c) &&
                     !accountContactsMap.get(ja.Company_Account__c).isEmpty()) {
                ja.Primary_Contact__c = accountContactsMap.get(ja.Company_Account__c).get(0).Id;
            }
        }
    }
}
}