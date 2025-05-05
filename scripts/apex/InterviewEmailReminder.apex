Account acct = new Account(
    Name = 'Test Account'
);

insert acct;

Event evt = new Event(
    Subject = 'Interview',
    StartDateTime = System.now() + 1,
    EndDateTime = System.now().addMinutes(60) + 1,
    Company__c = acct.Id,
    Location = 'Zoom: https://us06web.zoom.us/j/89722933470?pwd=ft2DsgdwbaPVejSSKDohWOaxyF7sht.1'
    );

insert evt;

InterviewEmailReminderHelper interview = new InterviewEmailReminderHelper(); 
interview.sendEmailReminder();