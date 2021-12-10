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

import ballerina/http;

class EventStream {
    private Event[] currentEntries = [];
    private string nextLink;
    private string? timeZone;
    private string? contentType;
    private string? queryParam;
    ConnectionConfig config;
    private int index = 0;
    private final http:Client httpClient;
    private final string path;

    isolated function init(ConnectionConfig config, http:Client httpClient, string path, TimeZone? timeZone = (), 
                                    ContentType? contentType = (), string? queryParam = ()) returns error? {
        self.config = config;
        self.httpClient = httpClient;
        self.path = path;
        self.nextLink = EMPTY_STRING;
        self.timeZone = timeZone;
        self.contentType = contentType;
        self.queryParam = queryParam;
        self.currentEntries = check self.fetchRecordsInitial();
    }

    public isolated function next() returns record {|Event value;|}|error? {
        if (self.index < self.currentEntries.length()) {
            record {|Event value;|} singleRecord = {value: self.currentEntries[self.index]};
            self.index += 1;
            return singleRecord;
        }
        // This code block is for retrieving the next batch of records when the initial batch is finished.
        if (self.nextLink != EMPTY_STRING && !self.queryParam.toString().includes("$top")) {
            self.index = 0;
            self.currentEntries = check self.fetchRecordsNext();
            record {|Event value;|} singleRecord = {value: self.currentEntries[self.index]};
            self.index += 1;
            return singleRecord;
        }
        return;
    }

    isolated function fetchRecordsInitial() returns Event[]|error {
        http:Response response 
            = check self.httpClient->get(self.path, preparePreferenceHeaderString(self.timeZone, self.contentType));
        _ = check handleResponse(response);
        return check self.getAndConvertToEventArray(response);
    }

    isolated function fetchRecordsNext() returns Event[]|error {
        http:Client nextPageClient = check new (self.nextLink, self.config);
        http:Response response 
            = check nextPageClient->get(EMPTY_STRING, preparePreferenceHeaderString(self.timeZone, self.contentType));
        return check self.getAndConvertToEventArray(response);
    }

    isolated function getAndConvertToEventArray(http:Response response) returns Event[]|error {
        Event[] events = [];
        map<json>|string? handledResponse = check handleResponse(response);
        if (handledResponse is map<json>) {
            self.nextLink = let var link = handledResponse["@odata.nextLink"]
                in link is string ? link : EMPTY_STRING;
            json values = check handledResponse.value;
            if (values is json[]) {
                foreach json item in values {
                    Event convertedItem = check item.cloneWithType(Event);
                    events.push(convertedItem);
                }
                return events;
            } else {
                return error(INVALID_PAYLOAD);
            }
        } else {
            return error(INVALID_RESPONSE);
        }
    }
}

class CalendarStream {
    private Calendar[] currentEntries = [];
    private string nextLink;
    private int index = 0;
    private final http:Client httpClient;
    private final string path;
    private string? queryParam;
    ConnectionConfig config;

    isolated function init(ConnectionConfig config, http:Client httpClient, string path, string? queryParam = ()) 
    returns error? {
        self.httpClient = httpClient;
        self.path = path;
        self.queryParam = queryParam;
        self.config = config;
        self.nextLink = EMPTY_STRING;
        self.currentEntries = check self.fetchRecordsInitial();
    }

    public isolated function next() returns record {|Calendar value;|}|error? {
        if (self.index < self.currentEntries.length()) {
            record {|Calendar value;|} singleRecord = {value: self.currentEntries[self.index]};
            self.index += 1;
            return singleRecord;
        }
        // This code block is for retrieving the next batch of records when the initial batch is finished.
        if (self.nextLink != EMPTY_STRING && !self.queryParam.toString().includes("$top")) {
            self.index = 0;
            self.currentEntries = check self.fetchRecordsNext();
            record {|Calendar value;|} singleRecord = {value: self.currentEntries[self.index]};
            self.index += 1;
            return singleRecord;
        }
        return;
    }

    isolated function fetchRecordsInitial() returns Calendar[]|error {
        http:Response response = check self.httpClient->get(self.path);
        _ = check handleResponse(response);
        return check self.getAndConvertToCalendarArray(response);
    }

    isolated function fetchRecordsNext() returns Calendar[]|error {
        http:Client nextPageClient = check new (self.nextLink, self.config);
        http:Response response = check nextPageClient->get(EMPTY_STRING);
        return check self.getAndConvertToCalendarArray(response);
    }

    isolated function getAndConvertToCalendarArray(http:Response response) returns Calendar[]|error {
        Calendar[] calendars = [];
        map<json>|string? handledResponse = check handleResponse(response);
        if (handledResponse is map<json>) {
            self.nextLink = let var link = handledResponse["@odata.nextLink"]
                in link is string ? link : EMPTY_STRING;
            json values = check handledResponse.value;
            if (values is json[]) {
                foreach json item in values {
                    Calendar convertedItem = check item.cloneWithType(Calendar);
                    calendars.push(convertedItem);
                }
                return calendars;
            } else {
                return error(INVALID_PAYLOAD);
            }
        } else {
            return error(INVALID_RESPONSE);
        }
    }
}
