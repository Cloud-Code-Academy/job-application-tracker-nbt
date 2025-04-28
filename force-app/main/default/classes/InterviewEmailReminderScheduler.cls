public with sharing class InterviewEmailReminderScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        new InterviewEmailReminderHelper().sendEmailReminder();
    }
}