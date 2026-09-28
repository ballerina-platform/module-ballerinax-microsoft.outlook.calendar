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

// Sets up a dedicated calendar for a project: finds or creates a calendar group, adds a
// project calendar to it, schedules the project milestones as all-day events on that
// calendar, and reads the calendar back to confirm the schedule.

import ballerina/io;
import ballerinax/microsoft.outlook.calendar;

type Milestone record {|
    string title;
    // First day of the milestone, as yyyy-MM-dd.
    string date;
    // Day after the milestone, as yyyy-MM-dd. All-day events end at midnight of the next day.
    string nextDate;
|};

# Milestones to schedule on the project calendar.
type MilestoneList Milestone[];

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string refreshUrl = ?;
configurable string groupName = ?;
configurable string calendarName = ?;
configurable MilestoneList milestones = ?;
configurable string timeZone = "UTC";

public function main() returns error? {
    calendar:Client calendarClient = check new ({
        auth: {clientId, clientSecret, refreshToken, refreshUrl}
    });

    // Step 1: reuse the calendar group if it already exists, otherwise create it.
    string groupId = check findOrCreateGroup(calendarClient, groupName);
    io:println("Calendar group: ", groupId);

    // Step 2: add a dedicated calendar for the project to the group.
    calendar:Calendar projectCalendar = check calendarClient->createGroupCalendar(groupId, {
        name: calendarName,
        color: "lightGreen"
    });
    string calendarId = projectCalendar.id ?: "";
    if calendarId == "" {
        return error("Outlook did not return an id for the new calendar");
    }
    io:println("Project calendar: ", calendarId);

    // Step 3: schedule each milestone as an all-day event on the project calendar.
    foreach Milestone milestone in milestones {
        calendar:Event created = check calendarClient->createGroupEvent(groupId, calendarId, {
            subject: milestone.title,
            isAllDay: true,
            showAs: "free",
            'start: <calendar:DateTimeTimeZone>{dateTime: milestone.date + "T00:00:00", timeZone},
            end: <calendar:DateTimeTimeZone>{dateTime: milestone.nextDate + "T00:00:00", timeZone},
            isReminderOn: true,
            reminderMinutesBeforeStart: 1440
        });
        io:println(string `Scheduled "${milestone.title}" (${created.id ?: "no id"})`);
    }

    // Step 4: read the project calendar back, following every page of results.
    calendar:EventCollection page = check calendarClient->listGroupEvents(groupId, calendarId,
        orderby = ["start/dateTime"], top = 50);
    int count = 0;
    while true {
        foreach calendar:Event event in page.value ?: [] {
            count += 1;
            io:println(string `  ${event?.subject ?: "(no subject)"}`);
        }
        string? nextLink = page?.atOdataNextLink;
        if nextLink is () {
            break;
        }
        // The client cannot request a raw URL, so this example uses offset paging: it
        // repeats the query with `skip` set to the number of events read so far.
        page = check calendarClient->listGroupEvents(groupId, calendarId, orderby = ["start/dateTime"],
            top = 50, skip = count);
    }
    io:println(string `${count} event(s) on "${calendarName}"`);
}

function findOrCreateGroup(calendar:Client calendarClient, string name) returns string|error {
    // OData string literals escape a single quote by doubling it.
    string escapedName = re `'`.replaceAll(name, "''");
    calendar:CalendarGroupCollection groups = check calendarClient->listCalendarGroups(filter = string `name eq '${escapedName}'`);
    calendar:CalendarGroup[] matches = groups.value ?: [];
    if matches.length() > 0 {
        string? existing = matches[0].id;
        if existing is string {
            return existing;
        }
    }
    calendar:CalendarGroup created = check calendarClient->createCalendarGroup({name});
    string? id = created.id;
    if id is () {
        return error("Outlook did not return an id for the new calendar group");
    }
    return id;
}
