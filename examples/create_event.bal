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

public function main() {
    calendar:EventMetadata eventMetadata = {
        subject: "Test-Subject",
        body: {
            content: "Test-Body"
        },
        'start: {
            dateTime: "2021-07-16T12:00:00",
            timeZone: calendar:TIMEZONE_LK
        },
        end: {
            dateTime: "2021-07-16T14:00:00",
            timeZone: calendar:TIMEZONE_LK
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
                'type: calendar:ATTENDEE_TYPE_REQUIRED,
                status: {
                    response: calendar:RESPONSE_NOT_RESPONDED
                }
            }
        ],
        allowNewTimeProposals: true
    };
    calendar:Event|error generatedEvent = calendarClient->createEvent(eventMetadata);
    if (response is calendar:Event) {
        log:printInfo(response.toString());
    }
}
