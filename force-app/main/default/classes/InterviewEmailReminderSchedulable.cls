public with sharing class InterviewEmailReminderSchedulable implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        new InterviewEmailReminderHelper().sendEmailReminder();
    }
}