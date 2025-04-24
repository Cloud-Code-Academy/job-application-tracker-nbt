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
    public override void afterInsert() {    
        createTasks(false); // No need to compare old and new — just create tasks
    }
    public override void afterUpdate() {    
        createTasks(true); // Compare old and new status
    }

public void createTasks(Boolean checkStatusChange) {
    List<Job_Application__c> jobApplicationsList = new List<Job_Application__c>();
    List<Task> tasksToInsert = new List<Task>();

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

    if(!jobApplicationsList.isEmpty()) {
        tasksToInsert = createTasksForStatus(jobApplicationsList);
    }

    if (!tasksToInsert.isEmpty()) {
        insert tasksToInsert;
    }

}

public List<Task> createTasksForStatus(List<Job_Application__c> jobAppList) {
    List<Task> tasks = new List<Task>();
    Date dueDate = Date.today().addDays(1); // Default due date = tomorrow

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

    for (Job_Application__c jobApp : jobAppList) {
        Id whoId = jobApp.Primary_Contact__c; // Optional: link to a contact if available
        List<String> subjects = taskMap.get(jobApp.Status__c);

        if (subjects != null) {
            for (String subject : subjects) {
                tasks.add(new Task(
                    Subject = subject,
                    Priority = 'Normal',
                    Status = 'Not Started',
                    ActivityDate = dueDate,
                    WhatId = jobApp.Id,
                    WhoId = whoId
                ));
            }
        }
    }

    return tasks;
}
}