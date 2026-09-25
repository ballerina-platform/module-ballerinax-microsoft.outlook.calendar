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

import ballerina/http;
import ballerina/os;
import ballerina/test;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
final string serviceUrl = isLiveServer ? "https://graph.microsoft.com/v1.0" : "http://localhost:9090";

final string clientId = isLiveServer ? os:getEnv("OUTLOOK_CLIENT_ID") : "test-client-id";
final string clientSecret = isLiveServer ? os:getEnv("OUTLOOK_CLIENT_SECRET") : "test-client-secret";
final string refreshToken = isLiveServer ? os:getEnv("OUTLOOK_REFRESH_TOKEN") : "test-refresh-token";
final string userId = isLiveServer ? os:getEnv("OUTLOOK_USER_ID") : "megan@contoso.com";
final string attendeeEmail = isLiveServer ? os:getEnv("OUTLOOK_ATTENDEE_EMAIL") : "alex@contoso.com";

final Client calendarClient = check initClient();

isolated function initClient() returns Client|error {
    if isLiveServer {
        return new ({
            auth: {
                clientId,
                clientSecret,
                refreshToken,
                refreshUrl: "https://login.microsoftonline.com/common/oauth2/v2.0/token"
            }
        }, serviceUrl);
    }
    // The mock listener is plain HTTP; HTTP/2 upgrade on PATCH bodies would time out against it.
    return new ({auth: {token: "test-token"}, httpVersion: http:HTTP_1_1}, serviceUrl);
}

isolated function eventPayload(string subject) returns Event => {
    subject,
    body: <ItemBody>{contentType: "text", content: "Created by the Ballerina connector test suite."},
    'start: <DateTimeTimeZone>{dateTime: "2026-10-01T09:00:00", timeZone: "UTC"},
    end: <DateTimeTimeZone>{dateTime: "2026-10-01T10:00:00", timeZone: "UTC"},
    attendees: [
        {
            'type: "required",
            emailAddress: <EmailAddress>{address: attendeeEmail}
        }
    ]
};

isolated function idOf(string? id) returns string|error {
    if id is () {
        return error("expected the created entity to carry an id");
    }
    return id;
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListEvents() returns error? {
    EventCollection response = check calendarClient->listEvents(top = 5);
    test:assertTrue((response.value ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateEvent() returns error? {
    Event response = check calendarClient->createEvent(eventPayload("Connector test: create event"));
    test:assertTrue(response?.id !is ());
    test:assertEquals(response?.subject, "Connector test: create event");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetEvent() returns error? {
    Event created = check calendarClient->createEvent(eventPayload("Connector test: get event"));
    string eventId = check idOf(created.id);
    Event response = check calendarClient->getEvent(eventId);
    test:assertEquals(response?.id, eventId);
    test:assertTrue(response?.subject !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testUpdateEvent() returns error? {
    Event created = check calendarClient->createEvent(eventPayload("Connector test: update event"));
    string eventId = check idOf(created.id);
    Event response = check calendarClient->updateEvent(eventId, {subject: "Connector test: updated event"});
    test:assertEquals(response?.subject, "Connector test: updated event");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testDeleteEvent() returns error? {
    Event created = check calendarClient->createEvent(eventPayload("Connector test: delete event"));
    string eventId = check idOf(created.id);
    error? response = calendarClient->deleteEvent(eventId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListCalendars() returns error? {
    CalendarCollection response = check calendarClient->listCalendars();
    test:assertTrue((response.value ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateCalendar() returns error? {
    Calendar response = check calendarClient->createCalendar({name: "Connector test calendar"});
    test:assertTrue(response?.id !is ());
    test:assertEquals(response?.name, "Connector test calendar");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetCalendar() returns error? {
    Calendar created = check calendarClient->createCalendar({name: "Connector test: get calendar"});
    string calendarId = check idOf(created.id);
    Calendar response = check calendarClient->getCalendar(calendarId);
    test:assertEquals(response?.id, calendarId);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testUpdateCalendar() returns error? {
    Calendar created = check calendarClient->createCalendar({name: "Connector test: update calendar"});
    string calendarId = check idOf(created.id);
    Calendar response = check calendarClient->updateCalendar(calendarId, {name: "Connector test: renamed calendar"});
    test:assertEquals(response?.name, "Connector test: renamed calendar");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testDeleteCalendar() returns error? {
    Calendar created = check calendarClient->createCalendar({name: "Connector test: delete calendar"});
    string calendarId = check idOf(created.id);
    error? response = calendarClient->deleteCalendar(calendarId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetDefaultCalendar() returns error? {
    Calendar response = check calendarClient->getDefaultCalendar();
    test:assertTrue(response?.id !is ());
    test:assertEquals(response?.isDefaultCalendar, true);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListCalendarView() returns error? {
    EventCollection response = check calendarClient->listCalendarView(
        startDateTime = "2026-10-01T00:00:00Z", endDateTime = "2026-10-02T00:00:00Z");
    test:assertTrue(response.value !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListCalendarEvents() returns error? {
    Calendar calendar = check calendarClient->createCalendar({name: "Connector test: calendar events"});
    string calendarId = check idOf(calendar.id);
    _ = check calendarClient->createCalendarEvent(calendarId, eventPayload("Connector test: calendar event"));
    EventCollection response = check calendarClient->listCalendarEvents(calendarId);
    test:assertTrue((response.value ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateCalendarEvent() returns error? {
    Calendar calendar = check calendarClient->createCalendar({name: "Connector test: create calendar event"});
    string calendarId = check idOf(calendar.id);
    Event response = check calendarClient->createCalendarEvent(calendarId,
        eventPayload("Connector test: event in a calendar"));
    test:assertTrue(response?.id !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListCalendarGroups() returns error? {
    CalendarGroupCollection response = check calendarClient->listCalendarGroups();
    test:assertTrue((response.value ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateCalendarGroup() returns error? {
    CalendarGroup response = check calendarClient->createCalendarGroup({name: "Connector test group"});
    test:assertTrue(response?.id !is ());
    test:assertEquals(response?.name, "Connector test group");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetCalendarGroup() returns error? {
    CalendarGroup created = check calendarClient->createCalendarGroup({name: "Connector test: get group"});
    string groupId = check idOf(created.id);
    CalendarGroup response = check calendarClient->getCalendarGroup(groupId);
    test:assertEquals(response?.id, groupId);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testDeleteCalendarGroup() returns error? {
    CalendarGroup created = check calendarClient->createCalendarGroup({name: "Connector test: delete group"});
    string groupId = check idOf(created.id);
    error? response = calendarClient->deleteCalendarGroup(groupId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListGroupCalendars() returns error? {
    CalendarGroupCollection groups = check calendarClient->listCalendarGroups();
    CalendarGroup[] values = groups.value ?: [];
    test:assertTrue(values.length() > 0);
    string groupId = check idOf(values[0].id);
    CalendarCollection response = check calendarClient->listGroupCalendars(groupId);
    test:assertTrue(response.value !is ());
}

// Responding to an invitation needs an event organised by someone else, which a fresh
// live tenant does not have, so the response actions run against the mock only.
@test:Config {groups: ["mock_tests"]}
isolated function testAcceptEvent() returns error? {
    error? response = calendarClient->acceptEvent("AAMkAGI2THVSAAA=", {comment: "See you there", sendResponse: true});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeclineEvent() returns error? {
    error? response = calendarClient->declineEvent("AAMkAGI2THVSAAA=", {
        comment: "Could we move this to the afternoon?",
        sendResponse: true,
        proposedNewTime: <TimeSlot>{
            'start: {dateTime: "2026-10-01T14:00:00", timeZone: "UTC"},
            end: {dateTime: "2026-10-01T15:00:00", timeZone: "UTC"}
        }
    });
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCancelEvent() returns error? {
    Event created = check calendarClient->createEvent(eventPayload("Connector test: cancel meeting"));
    string eventId = check idOf(created.id);
    error? response = calendarClient->cancelEvent(eventId, {comment: "Cancelled by the connector test suite"});
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testForwardEvent() returns error? {
    Event created = check calendarClient->createEvent(eventPayload("Connector test: forward event"));
    string eventId = check idOf(created.id);
    error? response = calendarClient->forwardEvent(eventId, {
        comment: "Forwarded by the connector test suite",
        toRecipients: [{emailAddress: <EmailAddress>{address: attendeeEmail}}]
    });
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListEventAttachments() returns error? {
    Event created = check calendarClient->createEvent(eventPayload("Connector test: list attachments"));
    string eventId = check idOf(created.id);
    _ = check calendarClient->createEventAttachment(eventId, fileAttachment("agenda.txt"));
    AttachmentCollection response = check calendarClient->listEventAttachments(eventId);
    test:assertTrue((response.value ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateEventAttachment() returns error? {
    Event created = check calendarClient->createEvent(eventPayload("Connector test: add attachment"));
    string eventId = check idOf(created.id);
    Attachment response = check calendarClient->createEventAttachment(eventId, fileAttachment("notes.txt"));
    test:assertTrue(response?.id !is ());
    test:assertEquals(response?.name, "notes.txt");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testDeleteEventAttachment() returns error? {
    Event created = check calendarClient->createEvent(eventPayload("Connector test: delete attachment"));
    string eventId = check idOf(created.id);
    Attachment attachment = check calendarClient->createEventAttachment(eventId, fileAttachment("remove-me.txt"));
    string attachmentId = check idOf(attachment.id);
    error? response = calendarClient->deleteEventAttachment(eventId, attachmentId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListEventInstances() returns error? {
    Event payload = eventPayload("Connector test: recurring event");
    payload.recurrence = <PatternedRecurrence>{
        pattern: <RecurrencePattern>{'type: "daily", interval: 1},
        range: <RecurrenceRange>{'type: "numbered", startDate: "2026-10-01", numberOfOccurrences: 3}
    };
    Event created = check calendarClient->createEvent(payload);
    string eventId = check idOf(created.id);
    EventCollection response = check calendarClient->listEventInstances(eventId,
        startDateTime = "2026-10-01T00:00:00Z", endDateTime = "2026-10-05T00:00:00Z");
    test:assertTrue((response.value ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testFindMeetingTimes() returns error? {
    MeetingTimeSuggestionsResult response = check calendarClient->findMeetingTimes({
        attendees: [{'type: "required", emailAddress: <EmailAddress>{address: attendeeEmail}}],
        meetingDuration: "PT30M",
        maxCandidates: 5
    });
    test:assertTrue(response?.meetingTimeSuggestions !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetCalendarSchedule() returns error? {
    Calendar calendar = check calendarClient->getDefaultCalendar();
    string calendarId = check idOf(calendar.id);
    ScheduleInformationCollection response = check calendarClient->getCalendarSchedule(calendarId, {
        schedules: [attendeeEmail],
        startTime: <DateTimeTimeZone>{dateTime: "2026-10-01T09:00:00", timeZone: "UTC"},
        endTime: <DateTimeTimeZone>{dateTime: "2026-10-01T18:00:00", timeZone: "UTC"},
        availabilityViewInterval: 60
    });
    test:assertTrue((response.value ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListUserEvents() returns error? {
    EventCollection response = check calendarClient->listUserEvents(userId, top = 5);
    test:assertTrue(response.value !is ());
}

isolated function fileAttachment(string name) returns Attachment => {
    atOdataType: "#microsoft.graph.fileAttachment",
    name,
    contentType: "text/plain",
    "contentBytes": "SGVsbG8gZnJvbSBCYWxsZXJpbmE="
};
