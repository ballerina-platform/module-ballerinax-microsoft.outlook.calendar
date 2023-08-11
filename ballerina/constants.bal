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

# Constant field `BASE_URL`. Holds the value of the Microsoft graph API's endpoint URL.
const string BASE_URL = "https://graph.microsoft.com/v1.0";

# Path parameters
const LOGGED_IN_USER = "me";
const EVENTS = "events";
const CALENDARS = "calendars";

# Symbols
const EQUAL_SIGN = "=";
const URL_PREFIX = "u!";
const EMPTY_STRING = "";
const DOLLAR_SIGN = "$";
const UNDERSCORE = "_";
const MINUS_SIGN = "-";
const PLUS_REGEX = "\\+";
const FORWARD_SLASH = "/";
const AMPERSAND = "&";
const QUESTION_MARK = "?";

# Numbers
const ZERO = 0;
const HUNDRED = 100.0;
const REQUEST_TIMEOUT = 180d;
const RETRY_ATTEMPTS = 5;
const RETRY_INTERVAL = 3d;
const BACKOFF_FACTOR = 2.0;
const MAX_WAIT = 20d;
const MAX_CHAR_COUNT = 2000;

# Error messages
const INVALID_RESPONSE = "Invalid response";
const INVALID_PAYLOAD = "Invalid payload";
const INVALID_MESSAGE = "Message cannot exceed 2000 characters";
const ASYNC_REQUEST_FAILED = "Asynchronous Job failed";
const INVALID_QUERY_PARAMETER = "Invalid query parameter";
const MAX_FRAGMENT_SIZE_EXCEEDED = "The content exceeds the maximum fragment size";

# Headers 
const PREFER = "Prefer";

# Enumeration - SystemQueryOption
enum SystemQueryOption {
    TOP = "top",
    COUNT = "count",
    SKIP = "skip",
    EXPAND = "expand",
    SELECT = "select",
    FILTER = "filter",
    ORDERBY = "orderby",
    SEARCH = "search",
    BATCH = "batch",
    FORMAT = "format"
}

# Enumeration - OpeningCharacters
enum OpeningCharacters {
    OPEN_BRACKET = "(",
    OPEN_SQUARE_BRACKET = "[",
    OPEN_CURLY_BRACKET = "{",
    SINGLE_QUOTE_O = "'",
    DOUBLE_QUOTE_O = "\""
}

# Enumeration - ClosingCharacters
enum ClosingCharacters {
    CLOSE_BRACKET = ")",
    CLOSE_SQUARE_BRACKET = "]",
    CLOSE_CURLY_BRACKET = "}",
    SINGLE_QUOTE_C = "'",
    DOUBLE_QUOTE_C = "\""
}
