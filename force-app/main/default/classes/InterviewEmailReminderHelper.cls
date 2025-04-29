public with sharing class InterviewEmailReminderHelper {

    public void sendEmailReminder() {
        // Query interviews that are scheduled for tomorrow
        Date tomorrow = Date.today().addDays(1);
        Datetime tomorrowStart = Datetime.newInstance(tomorrow, Time.newInstance(0, 0, 0, 0));
        Datetime tomorrowEnd = Datetime.newInstance(tomorrow, Time.newInstance(23, 59, 59, 999));
        List<Event> interviews = [  SELECT Id, StartDateTime, Subject, Location, CreatedBy.Name, CreatedBy.Email, Company__c, Company__r.Name
                                    FROM Event 
                                    WHERE StartDateTime >= :tomorrowStart AND StartDateTime <= :tomorrowEnd 
                                    AND Subject LIKE '%Interview%'  ];
        
        // If no interviews for tomorrow, exit
        if (interviews.isEmpty()) {
            System.debug('No interviews scheduled for tomorrow.');
            return;
        }

        // Prepare email messages
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Event event : interviews) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // Send email to person who created event
            email.setToAddresses(new String [] {event.CreatedBy.Email});
            email.setSubject('INTERVIEW REMINDER: Tomorrow ' + event.StartDateTime.format());
            // Set body of email
            String body = 'Hello ' + event.CreatedBy.Name + ',\n\n';
            body += 'This is a reminder that you have an upcoming interview scheduled for tomorrow.\n\n';
            body += 'Date and Time: ' + event.StartDateTime.format() + '\n';
            if (String.isNotBlank(event.Company__c)) {
                body += 'Company: ' + event.Company__r.Name + '\n';
            }
            if (String.isNotBlank(event.Location)) {
                body += 'Location: ' + event.Location + '\n';
            }
            body += '\n You got this!';
            email.setPlainTextBody(body);

            emails.add(email);
        }
        try {
            Messaging.sendEmail(emails);
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}