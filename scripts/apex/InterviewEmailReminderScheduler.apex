InterviewEmailReminderSchedulable email = new InterviewEmailReminderSchedulable();

// Schedule email reminder to run once daily at 7AM
String sch = '0 0 7 * * ?';
System.schedule('Interview Email Reminder - 7:00AM', sch, email);