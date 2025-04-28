public with sharing class InterviewEmailReminderHelper {

    public void sendEmailReminder() {
        // Get interviews that are scheduled for tomorrow
        Date tomorrow = Date.today().addDays(1);
        Datetime tomorrowStart = Datetime.newInstance(tomorrow, Time.newInstance(0, 0, 0, 0));
        Datetime tomorrowEnd = Datetime.newInstance(tomorrow, Time.newInstance(23, 59, 59, 999));

        List<Event> interviews = [  SELECT Id, OwnerId, WhatId, WhoId, ActivityDate, StartDateTime, Subject, Description, Location, CreatedById, CreatedBy.Email
                                    FROM Event 
                                    WHERE StartDateTime >= :tomorrowStart
                                    AND StartDateTime <= :tomorrowEnd 
                                    AND Subject LIKE '%Interview%'  ];

        if (interviews.isEmpty()) {
            System.debug('No interviews scheduled for tomorrow.');
            return;
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Event event : interviews) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String [] {event.CreatedBy.Email});
            email.setSubject('Interview Reminder: ' + event.StartDateTime.format());
            email.setPlainTextBody('This is a reminder that you have an upcoming interview on ' + event.StartDateTime.format() + '.');
            emails.add(email);
        }
        try {
            Messaging.sendEmail(emails);
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}