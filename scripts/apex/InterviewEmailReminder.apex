Event e = new Event(
    ActivityDate = System.today(),
    subject = 'new interview',
    startdatetime = System.now()+1,
    enddatetime = System.now().addMinutes(60)+1
    );

insert e;

InterviewEmailReminderHelper interview = new InterviewEmailReminderHelper(); 
interview.sendEmailReminder();