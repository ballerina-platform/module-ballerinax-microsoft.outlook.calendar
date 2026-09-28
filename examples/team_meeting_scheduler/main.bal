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
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

// Asks Outlook for meeting times when every attendee is free inside a time window, books the
// best suggestion as a Teams meeting, and lists what is now on the calendar in that window.

import ballerina/io;
import ballerinax/microsoft.outlook.calendar;

# Email addresses of the people who must attend.
type EmailList string[];

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string refreshUrl = ?;
configurable EmailList attendeeEmails = ?;
configurable string meetingSubject = ?;
configurable string windowStart = ?;
configurable string windowEnd = ?;
configurable string timeZone = "UTC";
configurable string meetingDuration = "PT30M";
// Creating the meeting sends an invitation to every attendee, so it is off unless enabled.
configurable boolean sendInvitations = false;

public function main() returns error? {
    calendar:Client calendarClient = check new ({
        auth: {clientId, clientSecret, refreshToken, refreshUrl}
    });

    calendar:AttendeeBase[] attendees = from string email in attendeeEmails
        select {'type: "required", emailAddress: <calendar:EmailAddress>{address: email}};

    // Step 1: ask for meeting times when all attendees are available in the window.
    calendar:MeetingTimeSuggestionsResult result = check calendarClient->findMeetingTimes({
        attendees,
        meetingDuration,
        maxCandidates: 5,
        returnSuggestionReasons: true,
        timeConstraint: <calendar:TimeConstraint>{
            activityDomain: "work",
            timeSlots: [
                {
                    'start: {dateTime: windowStart, timeZone},
                    end: {dateTime: windowEnd, timeZone}
                }
            ]
        }
    });

    calendar:MeetingTimeSuggestion[] suggestions = result.meetingTimeSuggestions ?: [];
    if suggestions.length() == 0 {
        return error(string `No meeting time found: ${result?.emptySuggestionsReason ?: "no reason given"}`);
    }
    calendar:TimeSlot|record {}? best = suggestions[0]?.meetingTimeSlot;
    if best !is calendar:TimeSlot {
        return error("The best suggestion carries no time slot");
    }
    calendar:DateTimeTimeZone? slotStart = best.'start;
    calendar:DateTimeTimeZone? slotEnd = best.end;
    if slotStart is () || slotEnd is () {
        return error("The best suggestion has no start or end time");
    }
    io:println(string `Best slot: ${slotStart?.dateTime ?: ""} to ${slotEnd?.dateTime ?: ""} (${slotStart?.timeZone ?: ""})`);
    io:println("Reason: ", suggestions[0]?.suggestionReason ?: "");

    if !sendInvitations {
        io:println("sendInvitations is false, so no meeting was created.");
        return;
    }

    // Step 2: book the suggested slot as an online meeting.
    calendar:Event meeting = check calendarClient->createEvent({
        subject: meetingSubject,
        'start: slotStart,
        end: slotEnd,
        attendees: from calendar:AttendeeBase attendee in attendees
            select {'type: "required", emailAddress: attendee.emailAddress},
        isOnlineMeeting: true,
        onlineMeetingProvider: "teamsForBusiness"
    });
    string meetingId = meeting?.id ?: "";
    if meetingId == "" {
        return error("Outlook did not return an id for the new meeting");
    }
    io:println("Created meeting ", meetingId);

    // Step 3: list everything in the window, which now includes the new meeting.
    calendar:EventCollection view = check calendarClient->listCalendarView(
        startDateTime = windowStart, endDateTime = windowEnd, orderby = ["start/dateTime"]);
    foreach calendar:Event event in view.value ?: [] {
        calendar:DateTimeTimeZone|record {}? eventStart = event?.'start;
        string startsAt = "";
        if eventStart is calendar:DateTimeTimeZone {
            startsAt = eventStart?.dateTime ?: "";
        }
        io:println(string `${startsAt}  ${event?.subject ?: "(no subject)"}`);
    }
}
