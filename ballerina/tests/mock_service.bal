// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/data.jsondata;
import ballerina/http;

listener http:Listener ep0 = new (9090);

service / on ep0 {
    # Delete a calendar group of the signed-in user
    #
    # + calendarGroupId - The unique identifier of calendarGroup
    # + ifMatch - ETag of the resource; the request succeeds only if it matches the current version
    # + return - returns can be any of following types 
    # http:NoContent (Success)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function delete me/calendarGroups/[string calendarGroupId](@http:Header {name: "If-Match"} string? ifMatch) returns http:NoContent|ODataErrorBadRequest|ODataErrorInternalServerError {
        return http:NO_CONTENT;
    }

    # Delete a calendar of the signed-in user
    #
    # + calendarId - The unique identifier of calendar
    # + ifMatch - ETag of the resource; the request succeeds only if it matches the current version
    # + return - returns can be any of following types 
    # http:NoContent (Success)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function delete me/calendars/[string calendarId](@http:Header {name: "If-Match"} string? ifMatch) returns http:NoContent|ODataErrorBadRequest|ODataErrorInternalServerError {
        return http:NO_CONTENT;
    }

    # Delete an event of the signed-in user
    #
    # + eventId - The unique identifier of event
    # + ifMatch - ETag of the resource; the request succeeds only if it matches the current version
    # + return - returns can be any of following types 
    # http:NoContent (Success)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function delete me/events/[string eventId](@http:Header {name: "If-Match"} string? ifMatch) returns http:NoContent|ODataErrorBadRequest|ODataErrorInternalServerError {
        return http:NO_CONTENT;
    }

    # Delete an attachment of an event of the signed-in user
    #
    # + eventId - The unique identifier of event
    # + attachmentId - The unique identifier of attachment
    # + ifMatch - ETag of the resource; the request succeeds only if it matches the current version
    # + return - returns can be any of following types 
    # http:NoContent (Success)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function delete me/events/[string eventId]/attachments/[string attachmentId](@http:Header {name: "If-Match"} string? ifMatch) returns http:NoContent|ODataErrorBadRequest|ODataErrorInternalServerError {
        return http:NO_CONTENT;
    }

    # Get the signed-in user's default calendar
    #
    # + 'select - Select properties to be returned
    # + expand - Expand related entities
    # + return - returns can be any of following types 
    # http:Ok (The retrieved me calendar)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function get me/calendar(@http:Query {name: "$select"} string[]? 'select, @http:Query {name: "$expand"} string[]? expand) returns Calendar|ODataErrorBadRequest|ODataErrorInternalServerError {
        return mockCalendar(DEFAULT_CALENDAR_ID, "Calendar", true);
    }

    # List the calendar groups of the signed-in user
    #
    # + top - Show only the first n items
    # + skip - Skip the first n items
    # + search - Search items by search phrases
    # + filter - Filter items by property values
    # + count - Include count of items
    # + orderby - Order items by property values
    # + 'select - Select properties to be returned
    # + expand - Expand related entities
    # + return - returns can be any of following types 
    # http:Ok (Retrieved collection)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function get me/calendarGroups(@http:Query {name: "$top"} int? top, @http:Query {name: "$skip"} int? skip, @http:Query {name: "$search"} string? search, @http:Query {name: "$filter"} string? filter, @http:Query {name: "$count"} boolean? count, @http:Query {name: "$orderby"} string[]? orderby, @http:Query {name: "$select"} string[]? 'select, @http:Query {name: "$expand"} string[]? expand) returns CalendarGroupCollection|ODataErrorBadRequest|ODataErrorInternalServerError {
        return {value: [mockCalendarGroup(CALENDAR_GROUP_ID, "My Calendars"), mockCalendarGroup("AAMkAGI2TGuLAAB=", "Project calendars")]};
    }

    # Get a calendar group of the signed-in user
    #
    # + calendarGroupId - The unique identifier of calendarGroup
    # + 'select - Select properties to be returned
    # + expand - Expand related entities
    # + return - returns can be any of following types 
    # http:Ok (The retrieved me calendar groups)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function get me/calendarGroups/[string calendarGroupId](@http:Query {name: "$select"} string[]? 'select, @http:Query {name: "$expand"} string[]? expand) returns CalendarGroup|ODataErrorBadRequest|ODataErrorInternalServerError {
        return mockCalendarGroup(calendarGroupId, "My Calendars");
    }

    # List the calendars in a calendar group of the signed-in user
    #
    # + calendarGroupId - The unique identifier of calendarGroup
    # + top - Show only the first n items
    # + skip - Skip the first n items
    # + search - Search items by search phrases
    # + filter - Filter items by property values
    # + count - Include count of items
    # + orderby - Order items by property values
    # + 'select - Select properties to be returned
    # + expand - Expand related entities
    # + return - returns can be any of following types 
    # http:Ok (Retrieved collection)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function get me/calendarGroups/[string calendarGroupId]/calendars(@http:Query {name: "$top"} int? top, @http:Query {name: "$skip"} int? skip, @http:Query {name: "$search"} string? search, @http:Query {name: "$filter"} string? filter, @http:Query {name: "$count"} boolean? count, @http:Query {name: "$orderby"} string[]? orderby, @http:Query {name: "$select"} string[]? 'select, @http:Query {name: "$expand"} string[]? expand) returns CalendarCollection|ODataErrorBadRequest|ODataErrorInternalServerError {
        return {value: [mockCalendar(DEFAULT_CALENDAR_ID, "Calendar", true), mockCalendar(CALENDAR_ID, "Team planning", false)]};
    }

    # List the event occurrences of the signed-in user in a time range
    #
    # + startDateTime - The start date and time of the time range, represented in ISO 8601 format. For example, 2019-11-08T19:00:00-08:00
    # + endDateTime - The end date and time of the time range, represented in ISO 8601 format. For example, 2019-11-08T20:00:00-08:00
    # + top - Show only the first n items
    # + skip - Skip the first n items
    # + search - Search items by search phrases
    # + filter - Filter items by property values
    # + count - Include count of items
    # + orderby - Order items by property values
    # + 'select - Select properties to be returned
    # + expand - Expand related entities
    # + return - returns can be any of following types 
    # http:Ok (Retrieved collection)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function get me/calendarView(string startDateTime, string endDateTime, @http:Query {name: "$top"} int? top, @http:Query {name: "$skip"} int? skip, @http:Query {name: "$search"} string? search, @http:Query {name: "$filter"} string? filter, @http:Query {name: "$count"} boolean? count, @http:Query {name: "$orderby"} string[]? orderby, @http:Query {name: "$select"} string[]? 'select, @http:Query {name: "$expand"} string[]? expand) returns EventCollection|ODataErrorBadRequest|ODataErrorInternalServerError {
        return {value: [mockEvent(EVENT_ID, "Sprint planning"), mockEvent("AAMkAGI2THVSAAB=", "Design review")]};
    }

    # List the calendars of the signed-in user
    #
    # + top - Show only the first n items
    # + skip - Skip the first n items
    # + search - Search items by search phrases
    # + filter - Filter items by property values
    # + count - Include count of items
    # + orderby - Order items by property values
    # + 'select - Select properties to be returned
    # + expand - Expand related entities
    # + return - returns can be any of following types 
    # http:Ok (Retrieved collection)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function get me/calendars(@http:Query {name: "$top"} int? top, @http:Query {name: "$skip"} int? skip, @http:Query {name: "$search"} string? search, @http:Query {name: "$filter"} string? filter, @http:Query {name: "$count"} boolean? count, @http:Query {name: "$orderby"} string[]? orderby, @http:Query {name: "$select"} string[]? 'select, @http:Query {name: "$expand"} string[]? expand) returns CalendarCollection|ODataErrorBadRequest|ODataErrorInternalServerError {
        return {value: [mockCalendar(DEFAULT_CALENDAR_ID, "Calendar", true), mockCalendar(CALENDAR_ID, "Team planning", false)]};
    }

    # Get a calendar of the signed-in user
    #
    # + calendarId - The unique identifier of calendar
    # + 'select - Select properties to be returned
    # + expand - Expand related entities
    # + return - returns can be any of following types 
    # http:Ok (The retrieved me calendars)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function get me/calendars/[string calendarId](@http:Query {name: "$select"} string[]? 'select, @http:Query {name: "$expand"} string[]? expand) returns Calendar|ODataErrorBadRequest|ODataErrorInternalServerError {
        return mockCalendar(calendarId, "Team planning", false);
    }

    # List the events in a calendar of the signed-in user
    #
    # + calendarId - The unique identifier of calendar
    # + top - Show only the first n items
    # + skip - Skip the first n items
    # + search - Search items by search phrases
    # + filter - Filter items by property values
    # + count - Include count of items
    # + orderby - Order items by property values
    # + 'select - Select properties to be returned
    # + expand - Expand related entities
    # + return - returns can be any of following types 
    # http:Ok (Retrieved collection)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function get me/calendars/[string calendarId]/events(@http:Query {name: "$top"} int? top, @http:Query {name: "$skip"} int? skip, @http:Query {name: "$search"} string? search, @http:Query {name: "$filter"} string? filter, @http:Query {name: "$count"} boolean? count, @http:Query {name: "$orderby"} string[]? orderby, @http:Query {name: "$select"} string[]? 'select, @http:Query {name: "$expand"} string[]? expand) returns EventCollection|ODataErrorBadRequest|ODataErrorInternalServerError {
        return {value: [mockEvent(EVENT_ID, "Sprint planning")]};
    }

    # List the events of the signed-in user
    #
    # + top - Show only the first n items
    # + skip - Skip the first n items
    # + search - Search items by search phrases
    # + filter - Filter items by property values
    # + count - Include count of items
    # + orderby - Order items by property values
    # + 'select - Select properties to be returned
    # + expand - Expand related entities
    # + return - returns can be any of following types 
    # http:Ok (Retrieved collection)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function get me/events(@http:Query {name: "$top"} int? top, @http:Query {name: "$skip"} int? skip, @http:Query {name: "$search"} string? search, @http:Query {name: "$filter"} string? filter, @http:Query {name: "$count"} boolean? count, @http:Query {name: "$orderby"} string[]? orderby, @http:Query {name: "$select"} string[]? 'select, @http:Query {name: "$expand"} string[]? expand) returns EventCollection|ODataErrorBadRequest|ODataErrorInternalServerError {
        return {value: [mockEvent(EVENT_ID, "Sprint planning"), mockEvent("AAMkAGI2THVSAAB=", "Design review")]};
    }

    # Get an event of the signed-in user
    #
    # + eventId - The unique identifier of event
    # + 'select - Select properties to be returned
    # + expand - Expand related entities
    # + return - returns can be any of following types 
    # http:Ok (The retrieved me events)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function get me/events/[string eventId](@http:Query {name: "$select"} string[]? 'select, @http:Query {name: "$expand"} string[]? expand) returns Event|ODataErrorBadRequest|ODataErrorInternalServerError {
        return mockEvent(eventId, "Sprint planning");
    }

    # List the attachments of an event of the signed-in user
    #
    # + eventId - The unique identifier of event
    # + top - Show only the first n items
    # + skip - Skip the first n items
    # + search - Search items by search phrases
    # + filter - Filter items by property values
    # + count - Include count of items
    # + orderby - Order items by property values
    # + 'select - Select properties to be returned
    # + expand - Expand related entities
    # + return - returns can be any of following types 
    # http:Ok (Retrieved collection)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function get me/events/[string eventId]/attachments(@http:Query {name: "$top"} int? top, @http:Query {name: "$skip"} int? skip, @http:Query {name: "$search"} string? search, @http:Query {name: "$filter"} string? filter, @http:Query {name: "$count"} boolean? count, @http:Query {name: "$orderby"} string[]? orderby, @http:Query {name: "$select"} string[]? 'select, @http:Query {name: "$expand"} string[]? expand) returns AttachmentCollection|ODataErrorBadRequest|ODataErrorInternalServerError {
        return {value: [mockAttachment(ATTACHMENT_ID, "agenda.txt")]};
    }

    # List the occurrences of a recurring event of the signed-in user
    #
    # + eventId - The unique identifier of event
    # + startDateTime - The start date and time of the time range, represented in ISO 8601 format. For example, 2019-11-08T19:00:00-08:00
    # + endDateTime - The end date and time of the time range, represented in ISO 8601 format. For example, 2019-11-08T20:00:00-08:00
    # + top - Show only the first n items
    # + skip - Skip the first n items
    # + search - Search items by search phrases
    # + filter - Filter items by property values
    # + count - Include count of items
    # + orderby - Order items by property values
    # + 'select - Select properties to be returned
    # + expand - Expand related entities
    # + return - returns can be any of following types 
    # http:Ok (Retrieved collection)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function get me/events/[string eventId]/instances(string startDateTime, string endDateTime, @http:Query {name: "$top"} int? top, @http:Query {name: "$skip"} int? skip, @http:Query {name: "$search"} string? search, @http:Query {name: "$filter"} string? filter, @http:Query {name: "$count"} boolean? count, @http:Query {name: "$orderby"} string[]? orderby, @http:Query {name: "$select"} string[]? 'select, @http:Query {name: "$expand"} string[]? expand) returns EventCollection|ODataErrorBadRequest|ODataErrorInternalServerError {
        Event first = mockEvent("AAMkAGI2THVSAAC=", "Weekly sync");
        first.'type = "occurrence";
        first.seriesMasterId = eventId;
        Event second = mockEvent("AAMkAGI2THVSAAD=", "Weekly sync");
        second.'type = "occurrence";
        second.seriesMasterId = eventId;
        return {value: [first, second]};
    }

    # List the events of a user
    #
    # + userId - The unique identifier of user
    # + top - Show only the first n items
    # + skip - Skip the first n items
    # + search - Search items by search phrases
    # + filter - Filter items by property values
    # + count - Include count of items
    # + orderby - Order items by property values
    # + 'select - Select properties to be returned
    # + expand - Expand related entities
    # + return - returns can be any of following types 
    # http:Ok (Retrieved collection)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function get users/[string userId]/events(@http:Query {name: "$top"} int? top, @http:Query {name: "$skip"} int? skip, @http:Query {name: "$search"} string? search, @http:Query {name: "$filter"} string? filter, @http:Query {name: "$count"} boolean? count, @http:Query {name: "$orderby"} string[]? orderby, @http:Query {name: "$select"} string[]? 'select, @http:Query {name: "$expand"} string[]? expand) returns EventCollection|ODataErrorBadRequest|ODataErrorInternalServerError {
        return {value: [mockEvent(EVENT_ID, "Quarterly business review")]};
    }

    # Update a calendar of the signed-in user
    #
    # + calendarId - The unique identifier of calendar
    # + payload - The me calendars properties to update 
    # + return - returns can be any of following types 
    # http:Ok (The updated calendar)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function patch me/calendars/[string calendarId](@http:Payload Calendar payload) returns Calendar|ODataErrorBadRequest|ODataErrorInternalServerError {
        Calendar updated = mockCalendar(calendarId, payload?.name ?: "Team planning", false);
        updated.color = payload.color;
        return updated;
    }

    # Update an event of the signed-in user
    #
    # + eventId - The unique identifier of event
    # + payload - The me events properties to update 
    # + return - returns can be any of following types 
    # http:Ok (The updated event)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function patch me/events/[string eventId](@http:Payload Event payload) returns Event|ODataErrorBadRequest|ODataErrorInternalServerError {
        Event updated = mockEvent(eventId, payload?.subject ?: "Sprint planning");
        return updated;
    }

    # Create a calendar group for the signed-in user
    #
    # + payload - The me calendar groups to create 
    # + return - returns can be any of following types 
    # http:Ok (The created me calendar groups)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function post me/calendarGroups(@http:Payload CalendarGroup payload) returns CalendarGroupOk|ODataErrorBadRequest|ODataErrorInternalServerError {
        return <CalendarGroupOk>{body: mockCalendarGroup("AAMkAGI2TGuLAAC=", payload?.name ?: "New group")};
    }

    # Create a calendar for the signed-in user
    #
    # + payload - The me calendars to create 
    # + return - returns can be any of following types 
    # http:Ok (The created me calendars)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function post me/calendars(@http:Payload Calendar payload) returns CalendarOk|ODataErrorBadRequest|ODataErrorInternalServerError {
        return <CalendarOk>{body: mockCalendar("AAMkAGI2TGuLAAD=", payload?.name ?: "New calendar", false)};
    }

    # Create an event in a calendar of the signed-in user
    #
    # + calendarId - The unique identifier of calendar
    # + payload - The me calendars events to create 
    # + return - returns can be any of following types 
    # http:Ok (The created me calendars events)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function post me/calendars/[string calendarId]/events(@http:Payload Event payload) returns EventOk|ODataErrorBadRequest|ODataErrorInternalServerError {
        return <EventOk>{body: mockEvent("AAMkAGI2THVSAAE=", payload?.subject ?: "New event")};
    }

    # Get the free/busy availability of users, lists or resources through a calendar of the signed-in user
    #
    # + calendarId - The unique identifier of calendar
    # + payload - Schedules to look up, the time period and the availability interval 
    # + return - returns can be any of following types 
    # http:Ok (The retrieved calendar schedule)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function post me/calendars/[string calendarId]/getSchedule(@http:Payload GetScheduleRequest payload) returns ScheduleInformationCollectionOk|ODataErrorBadRequest|ODataErrorInternalServerError {
        string[] schedules = payload?.schedules ?: [];
        ScheduleInformation[] info = from string schedule in schedules
            select {
                scheduleId: schedule,
                availabilityView: "0220",
                scheduleItems: [
                    {
                        subject: "Busy",
                        status: "busy",
                        'start: <DateTimeTimeZone>{dateTime: "2026-10-01T09:30:00.0000000", timeZone: "UTC"},
                        end: <DateTimeTimeZone>{dateTime: "2026-10-01T10:30:00.0000000", timeZone: "UTC"}
                    }
                ]
            };
        return <ScheduleInformationCollectionOk>{body: {value: info}};
    }

    # Create an event of the signed-in user
    #
    # + payload - The me events to create 
    # + return - returns can be any of following types 
    # http:Ok (The created me events)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function post me/events(@http:Payload Event payload) returns EventOk|ODataErrorBadRequest|ODataErrorInternalServerError {
        return <EventOk>{body: mockEvent("AAMkAGI2THVSAAF=", payload?.subject ?: "New event")};
    }

    # Accept an event of the signed-in user
    #
    # + eventId - The unique identifier of event
    # + payload - Optional comment and whether to send a response to the organizer 
    # + return - returns can be any of following types 
    # http:NoContent (Success)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function post me/events/[string eventId]/accept(@http:Payload AcceptEventRequest payload) returns http:NoContent|ODataErrorBadRequest|ODataErrorInternalServerError {
        return http:NO_CONTENT;
    }

    # Add an attachment to an event of the signed-in user
    #
    # + eventId - The unique identifier of event
    # + payload - The me events attachments to create 
    # + return - returns can be any of following types 
    # http:Ok (The created me events attachments)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function post me/events/[string eventId]/attachments(@http:Payload Attachment payload) returns AttachmentOk|ODataErrorBadRequest|ODataErrorInternalServerError {
        return <AttachmentOk>{body: mockAttachment("AAMkAGI2THVSAAG=", payload?.name ?: "attachment.txt")};
    }

    # Cancel a meeting of the signed-in user
    #
    # + eventId - The unique identifier of event
    # + payload - Optional cancellation message sent to the attendees 
    # + return - returns can be any of following types 
    # http:NoContent (Success)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function post me/events/[string eventId]/cancel(@http:Payload CancelEventRequest payload) returns http:NoContent|ODataErrorBadRequest|ODataErrorInternalServerError {
        return http:NO_CONTENT;
    }

    # Decline an event of the signed-in user
    #
    # + eventId - The unique identifier of event
    # + payload - Optional comment, proposed new time and whether to send a response to the organizer 
    # + return - returns can be any of following types 
    # http:NoContent (Success)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function post me/events/[string eventId]/decline(@http:Payload DeclineEventRequest payload) returns http:NoContent|ODataErrorBadRequest|ODataErrorInternalServerError {
        return http:NO_CONTENT;
    }

    # Forward an event of the signed-in user
    #
    # + eventId - The unique identifier of event
    # + payload - Recipients to forward the event to and an optional comment 
    # + return - returns can be any of following types 
    # http:NoContent (Success)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function post me/events/[string eventId]/forward(@http:Payload ForwardEventRequest payload) returns http:NoContent|ODataErrorBadRequest|ODataErrorInternalServerError {
        return http:NO_CONTENT;
    }

    # Suggest meeting times and locations for the signed-in user
    #
    # + payload - Attendees, time and location constraints for finding meeting times 
    # + return - returns can be any of following types 
    # http:Ok (Meeting time suggestions, or the reason none were found)
    # http:BadRequest (error)
    # http:InternalServerError (error)
    resource function post me/findMeetingTimes(@http:Payload FindMeetingTimesRequest payload) returns MeetingTimeSuggestionsResultOk|ODataErrorBadRequest|ODataErrorInternalServerError {
        MeetingTimeSuggestion suggestion = {
            confidence: 100,
            organizerAvailability: "free",
            suggestionReason: "Suggested because it is one of the nearest times when all attendees are available.",
            meetingTimeSlot: <TimeSlot>{
                'start: {dateTime: "2026-10-01T14:00:00.0000000", timeZone: "UTC"},
                end: {dateTime: "2026-10-01T14:30:00.0000000", timeZone: "UTC"}
            },
            attendeeAvailability: [
                {
                    availability: "free",
                    attendee: <AttendeeBase>{emailAddress: <EmailAddress>{address: "alex@contoso.com"}}
                }
            ]
        };
        return <MeetingTimeSuggestionsResultOk>{body: {meetingTimeSuggestions: [suggestion], emptySuggestionsReason: ""}};
    }
}

const DEFAULT_CALENDAR_ID = "AAMkAGI2TGuLAAA=";
const CALENDAR_ID = "AAMkAGI2TGuLAAE=";
const CALENDAR_GROUP_ID = "AAMkAGI2TGuLAAF=";
const EVENT_ID = "AAMkAGI2THVSAAA=";
const ATTACHMENT_ID = "AAMkAGI2THVSAAH=";

isolated function mockCalendar(string id, string name, boolean isDefault) returns Calendar => {
    id,
    name,
    color: "lightBlue",
    hexColor: "#a6d1f5",
    isDefaultCalendar: isDefault,
    canEdit: true,
    canShare: true,
    canViewPrivateItems: true,
    isRemovable: !isDefault,
    changeKey: "fJKVL07sbkmIfHqjbDnRgQAAAAACJA==",
    owner: <EmailAddress>{name: "Megan Bowen", address: "megan@contoso.com"}
};

isolated function mockCalendarGroup(string id, string name) returns CalendarGroup => {
    id,
    name,
    classId: "0006f0b7-0000-0000-c000-000000000046",
    changeKey: "Y+zDKLZlGkaXnZ6ztM9cDwAAAAAAEA=="
};

isolated function mockEvent(string id, string subject) returns Event => {
    id,
    subject,
    bodyPreview: "Agenda: review the backlog and agree on the sprint goal.",
    body: <ItemBody>{contentType: "html", content: "<p>Agenda: review the backlog and agree on the sprint goal.</p>"},
    'start: <DateTimeTimeZone>{dateTime: "2026-10-01T09:00:00.0000000", timeZone: "UTC"},
    end: <DateTimeTimeZone>{dateTime: "2026-10-01T10:00:00.0000000", timeZone: "UTC"},
    location: <Location>{displayName: "Conference Room 4B", locationType: "conferenceRoom"},
    attendees: [
        {
            'type: "required",
            emailAddress: <EmailAddress>{name: "Alex Wilber", address: "alex@contoso.com"},
            status: <ResponseStatus>{response: "accepted", time: "2026-09-25T08:00:00Z"}
        }
    ],
    organizer: <Recipient>{emailAddress: <EmailAddress>{name: "Megan Bowen", address: "megan@contoso.com"}},
    importance: "normal",
    showAs: "busy",
    sensitivity: "normal",
    'type: "singleInstance",
    isAllDay: false,
    isCancelled: false,
    isOrganizer: true,
    isReminderOn: true,
    reminderMinutesBeforeStart: 15,
    hasAttachments: false,
    webLink: "https://outlook.office365.com/owa/?itemid=" + id,
    createdDateTime: "2026-09-25T08:00:00Z",
    lastModifiedDateTime: "2026-09-25T08:05:00Z"
};

isolated function mockAttachment(string id, string name) returns Attachment => {
    atOdataType: "#microsoft.graph.fileAttachment",
    id,
    name,
    contentType: "text/plain",
    size: 1024,
    isInline: false,
    lastModifiedDateTime: "2026-09-25T08:10:00Z"
};

// Service-mode response types. `bal openapi --mode client` collapses 4XX/5XX
// to `error` and never emits these, so they are defined here for the mock only.
public type AttachmentOk record {|
    *http:Ok;
    Attachment body;
|};

public type CalendarGroupOk record {|
    *http:Ok;
    CalendarGroup body;
|};

public type CalendarOk record {|
    *http:Ok;
    Calendar body;
|};

public type EventOk record {|
    *http:Ok;
    Event body;
|};

public type MeetingTimeSuggestionsResultOk record {|
    *http:Ok;
    MeetingTimeSuggestionsResult body;
|};

public type ODataErrorBadRequest record {|
    *http:BadRequest;
    ODataError body;
|};

public type ODataErrorInternalServerError record {|
    *http:InternalServerError;
    ODataError body;
|};

public type ScheduleInformationCollectionOk record {|
    *http:Ok;
    ScheduleInformationCollection body;
|};

# Error response returned by Microsoft Graph
public type ODataError record {
    # The main error object of a Microsoft Graph error response
    MainError 'error;
};

# The main error object of a Microsoft Graph error response
public type MainError record {
    # Service-defined error code
    string code;
    # Additional details about the error
    ErrorDetails[] details?;
    # Internal error details of a Microsoft Graph error
    InnerError innerError?;
    # Human-readable description of the error
    string message;
    # Target of the error, such as the name of the property in error
    string? target?;
};

# Internal error details of a Microsoft Graph error
public type InnerError record {
    # Date when the error occured
    string? date?;
    # Client request Id as sent by the client application
    @jsondata:Name {value: "client-request-id"}
    string? clientRequestId?;
    # The OData type annotation identifying the entity or complex type of the object
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Request Id as tracked internally by the service
    @jsondata:Name {value: "request-id"}
    string? requestId?;
};

# Detail of a Microsoft Graph error
public type ErrorDetails record {
    # Service-defined error code
    string code;
    # Human-readable description of the error
    string message;
    # Target of the error, such as the name of the property in error
    string? target?;
};
