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

import ballerina/config;
import ballerina/io;
import ballerina/log;
import ballerinax/sfdc;
import ballerinax/googleapis_sheets as sheets4;

sfdc:SalesforceConfiguration sfConfig = {
    baseUrl: config:getAsString("SF_EP_URL"),
    clientConfig: {
        accessToken: config:getAsString("SF_ACCESS_TOKEN"),
        refreshConfig: {
            clientId: config:getAsString("SF_CLIENT_ID"),
            clientSecret: config:getAsString("SF_CLIENT_SECRET"),
            refreshToken: config:getAsString("SF_REFRESH_TOKEN"),
            refreshUrl: config:getAsString("SF_REFRESH_URL")
        }
    }
};

sheets4:SpreadsheetConfiguration spreadsheetConfig = {
    oauth2Config: {
        accessToken: config:getAsString("GS_ACCESS_TOKEN"),
        refreshConfig: {
            clientId: config:getAsString("GS_CLIENT_ID"),
            clientSecret: config:getAsString("GS_CLIENT_SECRET"),
            refreshUrl: config:getAsString("GS_REFRESH_URL"),
            refreshToken: config:getAsString("GS_REFRESH_TOKEN")
        }
    }
};

sfdc:ListenerConfiguration listenerConfig = {
    username: config:getAsString("SF_USERNAME"),
    password: config:getAsString("SF_PASSWORD")
};

listener sfdc:Listener sfdcEventListener = new (listenerConfig);
sfdc:BaseClient sfdcClient = new (sfConfig);
sheets4:Client gSheetClient = new (spreadsheetConfig);

@sfdc:ServiceConfig {topic:config:getAsString("SF_CASE_TOPIC")}
service on sfdcEventListener {
    remote function onEvent(json case) {
        io:StringReader sr = new (case.toJsonString());
        json|error caseInfo = sr.readJson();
        if (caseInfo is json) {
            if(CREATED.equalsIgnoreCaseAscii(caseInfo.event.'type.toString())){
                var caseId = caseInfo.sobject.Id;
                log:print("Case ID = "+caseId.toString());
                var caseRecord = sfdcClient->getRecordById("Case",caseId.toString());
                if(caseRecord is json){
                   [string,string]|error? response = createSheetWithNewCase(caseRecord);
                   if (response is [string, string]) {
                      log:print("Spreadsheet with ID "+response[0]+" is created for new Salesforce Case Number "
                      +response[1]); 
                   }
                   else{
                       log:printError(response.toString());
                   }
                }
                else {
                    log:printError(caseRecord.toString());
                }
            }        
        }
        else
        {
            log:printError(caseInfo.toString());
        }
    }
}

function createSheetWithNewCase(json case) returns @tainted [string,string] | error?{
    string caseNumber = case.CaseNumber.toString();
    sheets4:Spreadsheet spreadsheet = check gSheetClient->createSpreadsheet("Salesforce Case "+caseNumber);
    string spreadsheetId = spreadsheet.spreadsheetId;
    sheets4:Sheet sheet = check spreadsheet.getSheetByName("Sheet1");
    map<json> caseMap = <map<json>> case;
    foreach var [key, value] in caseMap.entries() {
        var response = sheet->appendRow([key, value.toString()]);
        if(response is error){
            log:printError(response.message());
        }
    } 
    return [spreadsheetId, caseNumber];
}
