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
import ballerina/log;

isolated function createUrl(string[] pathParameters, string? queryParameters = ()) returns string|error {
    string url = EMPTY_STRING;
    if (pathParameters.length() > ZERO) {
        foreach string element in pathParameters {
            if (!element.startsWith(FORWARD_SLASH)) {
                url = url + FORWARD_SLASH;
            }
            url += element;
        }
    }
    if (queryParameters is string) {
        url = url + QUESTION_MARK + queryParameters;
    }
    return url;
}

isolated function handleResponse(http:Response httpResponse) returns map<json>|error? {
    if (httpResponse.statusCode is http:STATUS_OK|http:STATUS_CREATED|http:STATUS_ACCEPTED) {
        json jsonResponse = check httpResponse.getJsonPayload();
        return <map<json>>jsonResponse;
    } else if (httpResponse.statusCode is http:STATUS_NO_CONTENT) {
        return;
    }
    json errorPayload = check httpResponse.getJsonPayload();
    string message = errorPayload.toString(); // Error should be defined as a user defined object
    return error (message);
}

isolated function preparePreferenceHeaderString(string? timeZone, string? contentType) returns map<string> {
    map<string> header = {};
    if(timeZone is string && contentType is string) {
        header = {[PREFER] : string `outlook.timezone="${timeZone.toString()}", outlook.body-content-type="${contentType.toString()}"`};
    }
    else if (timeZone is string) {
        header = {[PREFER] : string `outlook.timezone="${timeZone.toString()}"`};
    }
    else if (contentType is string) {
        header = {[PREFER] : string `outlook.body-content-type="${contentType.toString()}"`};
    }
    log:printDebug(header.toString());
    return header;
}

# Sets required request headers.
# 
# + request - Request object reference
# + specificRequiredHeaders - Request headers as a key value map
isolated function setSpecificRequestHeaders(http:Request request, map<string> specificRequiredHeaders) {
    string[] keys = specificRequiredHeaders.keys();
    foreach string keyItem in keys {
        request.setHeader(keyItem, specificRequiredHeaders.get(keyItem));
    }
}
