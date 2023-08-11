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

import ballerina/log;
import ballerinax/microsoft.outlook.calendar;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string refreshUrl = ?;

calendar:ConnectionConfig configuration = {
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshToken: refreshToken,
        refreshUrl: refreshUrl
    }
};

calendar:Client calendarClient = check new (configuration);
string eventId = "eventId";

public function main() {
    calendar:EventMetadata eventBody = {
        subject: "Changed the Subject during Update Event",
        isAllDay: false, // if this is true, you need to provide `Start` and `End` also.
        'start: {
            dateTime: "2015-09-08T00:00:00.000Z",
            timeZone: calendar:TIMEZONE_AD
        },
        end: {
            dateTime: "2015-09-09T00:00:00.000Z",
            timeZone: calendar:TIMEZONE_AD
        },
        responseStatus: {
            response: calendar:RESPONSE_ACCEPTED
        },
        recurrence: null,
        importance: calendar:IMPORTANCE_HIGH,
        reminderMinutesBeforeStart: 99,
        isOnlineMeeting: true,
        sensitivity: calendar:SENSITIVITY_PERSONAL,
        showAs: calendar:SHOW_AS_BUSY,
        onlineMeetingProvider: calendar:ONLINE_MEETING_PROVIDER_TYPE_TEAMS_FOR_BUSINESS,
        isReminderOn: true,
        hideAttendees: false,
        responseRequested: true,
        categories: ["Red category"]
    };
    calendar:Event|error response = calendarClient->updateEvent(eventId, eventBody);
    if (response is calendar:Event) {
        log:printInfo(response.toString());
    }
}
