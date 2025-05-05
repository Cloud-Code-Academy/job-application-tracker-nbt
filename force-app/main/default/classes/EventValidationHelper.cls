public with sharing class EventValidationHelper {
    public static void validateNoOverlappingEvents(List<Event> newEvents, Boolean isInsert) {
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

        // Exit early if no meaningful time range
        if (minStart == null || maxEnd == null || ownerIds.isEmpty()) {
            return;
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
        // For each new event check if there is not start date time, end date time or owner, skip it
        for (Event newEv : newEvents) {
            if (newEv.StartDateTime == null || newEv.EndDateTime == null || newEv.OwnerId == null) {
                continue;
            }
            // For each existing event
            for (Event existingEv : existingEvents) {
                // Skip self on update
                if (!isInsert && existingEv.Id == newEv.Id) {
                    continue;
                }
                // If both events have the same owner AND they overlap in time, add an error to the new event saying it overlaps. Stop checking others
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