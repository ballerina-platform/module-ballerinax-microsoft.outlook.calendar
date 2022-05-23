// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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

import ballerina/io;
import ballerina/log;
import ballerina/test;
import ballerina/os;

configurable string refreshUrl = os:getEnv("REFRESH_URL");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");

ConnectionConfig configuration = {
    auth: {
        refreshUrl: refreshUrl,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
    }
};

Client calendarClient = check new (configuration);

string eventId = "";
string calendarId = "";
string queryParamSelect = "$select=subject";
string queryParamTop = "$top=5";
string queryParamCount = "$count=true";

# Tests related to `Event` resource operations
# Test - Get `Event` by ID
@test:Config {
    enable: true,
    groups: ["events"],
    dependsOn: [testCreateEvent]
}
function testGetEvent() {
    log:printInfo("client->testGetEvent()");
    Event|error event = calendarClient->getEvent(eventId);
    if (event is Event) {
        test:assertEquals(event.id, eventId, "Invalid Event ID");
        log:printInfo("Event received with ID : " + event.id.toString());
    } else {
        test:assertFail(msg = event.message());
    }
    io:println("\n\n");
}

# Test - Get `Event` by ID using preference headers like timezone, content type
@test:Config {
    enable: true,
    groups: ["events"],
    dependsOn: [testCreateEvent]
}
function testGetEventWithPreferenceHeaders() {
    log:printInfo("client->testGetEventWithPreferenceHeaders()");
    Event|error event = calendarClient->getEvent(eventId, timeZone = TIMEZONE_AD, contentType = CONTENT_TYPE_TEXT);
    if (event is Event) {
        test:assertEquals(event.id, eventId, "Invalid Event ID");
        log:printInfo("Event received with requested timezone : " + event?.'start?.timeZone.toString());
    } else {
        test:assertFail(msg = event.message());
    }
    io:println("\n\n");
}

# Test - Get `Event` with Query parameters 
# More details : https://docs.microsoft.com/en-us/graph/query-parameters
@test:Config {
    enable: true,
    groups: ["events"],
    dependsOn: [testCreateEvent]
}
function testGetEventWithQueryParameters() {
    log:printInfo("client->testGetEventWithPreferenceHeaders()");
    Event|error event = calendarClient->getEvent(eventId, queryParams = queryParamSelect);
    if (event is Event) {
        test:assertEquals(event.id, eventId, "Invalid Event ID");
        log:printInfo("Event received with ID: " + event.id.toString());
    } else {
        test:assertFail(msg = event.message());
    }
    io:println("\n\n");
}

# Test - Get list of `Events`
# + return - error or null on failure.
@test:Config {
    enable: true,
    groups: ["events"]
}
function testListEvents() returns error? {
    log:printInfo("client->testListEvents()");
    stream<Event, error?>|error eventStream
        = calendarClient->listEvents(timeZone = TIMEZONE_AD, contentType = CONTENT_TYPE_TEXT, queryParams = queryParamTop);
    if (eventStream is stream<Event, error?>) {
        _ = check eventStream.forEach(isolated function(Event event) {
            test:assertNotEquals(event.id, EMPTY_STRING, "Empty Event ID");
            log:printInfo(event.id.toString());
        });
    } else {
        test:assertFail(msg = eventStream.message());
    }
    io:println("\n\n");
}

# Test - Create an `Event` quickly with minimum details needed
@test:Config {
    groups: ["events"],
    enable: true
}
function testAddQuickEvent() {
    log:printInfo("client->testAddQuickEvent()");
    string subject = "Test-Subject";
    string body = "Test-Body";
    Event|error event = calendarClient->addQuickEvent(subject, body);
    if (event is Event) {
        test:assertNotEquals(event.id, EMPTY_STRING, "Empty Event ID");
        eventId = event.id.toString();
        log:printInfo("Event created with ID : " + eventId);
    } else {
        log:printError(event.toString());
        test:assertFail(msg = event.message());
    }
    io:println("\n\n");
}

# Test - Create an `Event` by providing `EventMetadata` body
@test:Config {
    enable: true,
    groups: ["events"]
}
function testCreateEvent() {
    log:printInfo("client->testCreateEvent()");
    EventMetadata eventMetadata = {
        subject: "Test-Subject",
        body: {
            content: "Test-Body"
        },
        'start: {
            dateTime: "2021-07-16T12:00:00",
            timeZone: TIMEZONE_LK
        },
        end: {
            dateTime: "2021-07-16T14:00:00",
            timeZone: TIMEZONE_LK
        },
        location: {
            displayName: "Harry's Bar"
        },
        attendees: [
            {
                emailAddress: {
                    address: "samanthab@contoso.onmicrosoft.com",
                    name: "Samantha Booth"
                },
                'type: ATTENDEE_TYPE_REQUIRED,
                status: {
                    response: RESPONSE_NOT_RESPONDED
                }
            }
        ],
        allowNewTimeProposals: true
    };
    Event|error generatedEvent = calendarClient->createEvent(eventMetadata);
    if (generatedEvent is Event) {
        test:assertNotEquals(generatedEvent.id, EMPTY_STRING, "Empty Event ID");
        eventId = generatedEvent.id.toString();
        log:printInfo("Event created with ID : " + eventId.toString());
    } else {
        test:assertFail(msg = generatedEvent.message());
    }
    io:println("\n\n");
}

# Test - Create an `Event` with multiple locations
@test:Config {
    groups: ["events"],
    enable: true
}
function testCreateEventWithMultipleLocations() {
    log:printInfo("client->testCreateEventWithMultipleLocations()");
    EventMetadata eventMetadata = {
        subject: "Plan summer company picnic",
        body: {
            contentType: "text",
            content: "Let's kick-start this event planning!"
        },
        'start: {
            dateTime: "2021-08-30T11:00:00",
            timeZone: "Pacific Standard Time"
        },
        end: {
            dateTime: "2021-08-30T12:00:00",
            timeZone: "Pacific Standard Time"
        },
        attendees: [
            {
                emailAddress: {
                    address: "DanaS@contoso.onmicrosoft.com",
                    name: "Dana"
                },
                'type: ATTENDEE_TYPE_REQUIRED
            },
            {
                emailAddress: {
                    address: "AlexW@contoso.onmicrosoft.com",
                    name: "Alex Wilber"
                },
                'type: ATTENDEE_TYPE_OPTIONAL
            }
        ],
        location: {
            displayName: "Conf Room 3; Fourth Coffee; Home Office",
            locationType: LOCATION_TYPE_DEFAULT
        },
        locations: [
            {
                displayName: "Conf Room 3"
            },
            {
                displayName: "Fourth Coffee",
                address: {
                    street: "4567 Main St",
                    city: "Redmond",
                    state: "WA",
                    countryOrRegion: "US",
                    postalCode: "32008"
                },
                coordinates: {
                    latitude: 47.672,
                    longitude: -102.103
                }
            },
            {
                displayName: "Home Office"
            }
        ],
        allowNewTimeProposals: true
    };
    Event|error generatedEvent = calendarClient->createEvent(eventMetadata);
    if (generatedEvent is Event) {
        test:assertNotEquals(generatedEvent.id, EMPTY_STRING, "Empty Event ID");
        eventId = generatedEvent.id.toString();
        log:printInfo("Event created with ID : " + eventId);
    } else {
        test:assertFail(msg = generatedEvent.message());
    }
    io:println("\n\n");
}

# Test - Update an `Event` by providing `EventMetadata` body
@test:Config {
    enable: true,
    groups: ["events"],
    dependsOn: [testCreateEvent]
}
function testUpdateEvent() {
    log:printInfo("client->testUpdateEvent()");
    EventMetadata eventBody = {
        subject: "Changed the Subject during Update Event",
        isAllDay: false, // if this is true, you need to provide `Start` and `End` also.
        'start: {
            dateTime: "2015-09-08T00:00:00.000Z",
            timeZone: TIMEZONE_AD
        },
        end: {
            dateTime: "2015-09-09T00:00:00.000Z",
            timeZone: TIMEZONE_AD
        },
        responseStatus: {
            response: RESPONSE_ACCEPTED
        },
        recurrence: null,
        importance: IMPORTANCE_HIGH,
        reminderMinutesBeforeStart: 99,
        isOnlineMeeting: true,
        sensitivity: SENSITIVITY_PERSONAL,
        showAs: SHOW_AS_BUSY,
        onlineMeetingProvider: ONLINE_MEETING_PROVIDER_TYPE_TEAMS_FOR_BUSINESS,
        isReminderOn: true,
        hideAttendees: false,
        responseRequested: true,
        categories: ["Red category"]
    };
    Event|error response = calendarClient->updateEvent(eventId, eventBody);
    if (response is Event) {
        test:assertEquals(response.id, eventId, "Invalid Event ID");
        log:printInfo("Event updated, Event ID : " + response.id.toString());
    } else {
        test:assertFail(msg = response.message());
    }
    io:println("\n\n");
}

# Tests related to `Calendar` resource operations
#
# Test - Get a `Calendar` by ID
@test:Config {
    enable: true,
    groups: ["calendars"],
    dependsOn: [testCreateCalendar]
}
function testGetCalendar() {
    log:printInfo("client->testGetCalendar()");
    Calendar|error response = calendarClient->getCalendar(calendarId);
    if (response is Calendar) {
        test:assertEquals(response.id.toString(), calendarId, "Invalid Calender ID.");
        log:printInfo("Calendar received with ID : " + response.id.toString());
    } else {
        log:printError(response.toString());
        test:assertFail(msg = response.message());
    }
    io:println("\n\n");
}

# Test - Update a `Calendar` with name, color, default properties
@test:Config {
    enable: true,
    groups: ["calendars"],
    dependsOn: [testCreateCalendar]
}
function testUpdateCalendar() {
    log:printInfo("client->testUpdateCalendar()");
    string newName = "Updated ballerina calendar";
    CalendarColor newColor = CALENDAR_COLOR_AUTO;
    boolean makeDefault = false;
    Calendar|error response = calendarClient->updateCalendar(calendarId, newName, newColor, makeDefault);
    if (response is Calendar) {
        test:assertEquals(response.id.toString(), calendarId, "Invalid Calender ID.");
        log:printInfo("Calendar updated, Calendar ID : " + response.toString());
    } else {
        log:printError(response.toString());
        test:assertFail(msg = response.message());
    }
    io:println("\n\n");
}

# Test - List `Calendars` 
# + return - error or null on failure. 
@test:Config {
    enable: true,
    groups: ["calendars"],
    dependsOn: [testCreateCalendar]
}
function testListCalendars() returns error? {
    log:printInfo("client->testListCalendars()");
    stream<Calendar, error?>|error eventStream = calendarClient->listCalendars(queryParams = queryParamTop);
    if (eventStream is stream<Calendar, error?>) {
        _ = check eventStream.forEach(isolated function(Calendar calendar) {
            test:assertNotEquals(calendar.id.toString(), EMPTY_STRING, "Empty Calender ID.");
            log:printInfo(calendar.id.toString());
        });
    } else {
        test:assertFail(msg = eventStream.message());
    }
    io:println("\n\n");
}

# Test - Create a `Calendar` providing `CalendarMetadata` object
@test:Config {
    enable: true,
    groups: ["calendars"]
}
function testCreateCalendar() {
    log:printInfo("client->testCreateCalendar()");
    CalendarMetadata calendarMetadata = {
        name: "Ballerina-Test-Calendar"
    };
    Calendar|error response = calendarClient->createCalendar(calendarMetadata);
    if (response is Calendar) {
        test:assertNotEquals(response.id.toString(), EMPTY_STRING, "Empty Calender ID.");
        calendarId = response.id.toString();
        log:printInfo("Calendar created with ID : " + calendarId);
    } else {
        log:printError(response.toString());
        test:assertFail(msg = response.message());
    }
    io:println("\n\n");
}

@test:AfterSuite {}
function afterSuiteDeleteEventandCalendar() {
    log:printInfo("client->testDeleteCalendar()");
    error? deleteResponse = calendarClient->deleteCalendar(calendarId);
    if (deleteResponse is error) {
        test:assertFail(msg = deleteResponse.message());
    } else {
        log:printInfo("Calendar deleted with ID : " + calendarId);
    }
    io:println("\n\n");

    log:printInfo("client->testDeleteEvent()");
    error? deleteEvent = calendarClient->deleteEvent(eventId);
    if (deleteEvent is error) {
        test:assertFail(msg = deleteEvent.message());
    } else {
        log:printInfo("Event deleted with ID : " + eventId);
    }
    io:println("\n\n");
}
