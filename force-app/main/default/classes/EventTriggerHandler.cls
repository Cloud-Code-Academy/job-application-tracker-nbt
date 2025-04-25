public class EventTriggerHandler extends TriggerHandler{
    private List<Event> newEvents;
    private Map<Id, Event> newEventMap;
    private List<Event> oldEvents;
    private Map<Id, Event> oldEventMap;

    public EventTriggerHandler() {
        this.newEvents = (List<Event>) Trigger.new;
        this.newEventMap = (Map<Id, Event>) Trigger.newMap;
        this.oldEvents = (List<Event>) Trigger.old;
        this.oldEventMap = (Map<Id, Event>) Trigger.oldMap;
    }
    
    
    public override void beforeInsert() {
        validateNoOverlappingEvents(this.newEvents);
    }

    public override void beforeUpdate() {
        validateNoOverlappingEvents(this.newEvents);
    }
    
        
    public static void validateNoOverlappingEvents(List<Event> newEvents) {
        // Gather all OwnerIds from the new events
        Set<Id> ownerIds = new Set<Id>();
        for (Event ev : newEvents) {
            if (ev.OwnerId != null) {
                ownerIds.add(ev.OwnerId);
            }
        }

        // Date range filter to limit the query size
        DateTime minStart = null;
        DateTime maxEnd = null;

        for (Event ev : newEvents) {
            // Check if each Event has a start and end date time and update variables with the earliest start date time and the latest end date time
            if (ev.StartDateTime != null && ev.EndDateTime != null) {
                if (minStart == null || ev.StartDateTime < minStart) {
                    minStart = ev.StartDateTime;
                }
                if (maxEnd == null || ev.EndDateTime > maxEnd) {
                    maxEnd = ev.EndDateTime;
                }
            }
        }        

        // Query existing events that may overlap (same owner, within date range)
        List<Event> existingEvents = [
            SELECT Id, OwnerId, StartDateTime, EndDateTime
            FROM Event
            WHERE OwnerId IN :ownerIds
            AND StartDateTime < :maxEnd
            AND EndDateTime > :minStart
        ];

        // Check each new event for overlaps
        for (Event newEv : newEvents) {
            if (newEv.StartDateTime == null || newEv.EndDateTime == null || newEv.OwnerId == null) {
                continue;
            }

            for (Event existingEv : existingEvents) {
                // Skip self on update
                if (!Trigger.isInsert && existingEv.Id == newEv.Id) {
                    continue;
                }

                if (existingEv.OwnerId == newEv.OwnerId &&
                    newEv.StartDateTime < existingEv.EndDateTime &&
                    newEv.EndDateTime > existingEv.StartDateTime) {
                        newEv.addError('This event overlaps with another event on the calendar.');
                        break;
                }
            }
        }
    }
}