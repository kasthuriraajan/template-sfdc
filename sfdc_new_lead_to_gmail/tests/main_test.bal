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
import ballerina/test;
import ballerina/runtime;

json testLeadRecord = {"event":{"createdDate":"2021-02-03T06:49:36.232Z","replayId":11,"type":"created"},"sobject":{"Status":"Open - Not Contacted","Company":"WSO2","Email":"sliit.sk95.sk95@gmail.com","Phone":"0775856964","Title":null,"Id":"00Q5g0000010x1nEAA","Name":"Nuwan Tissera"}};
string testUserId = "me";
string sentHtmlMessageId = "";

@test:Config {}
function testGmailAlerts() {
    log:print("gmailClient -> testGmailAlerts()");
    var sendMessageResponse = sendGmailAlert(testLeadRecord);

    if (sendMessageResponse is [string, string]) {
        [string, string][messageId, threadId] = sendMessageResponse;
        sentHtmlMessageId = <@untainted>messageId;
        test:assertTrue(messageId != "null" && threadId != "null", msg = "Send Text Message Failed");
    } else {
        test:assertFail(msg = sendMessageResponse.toString());
    }
    runtime:sleep(15000); //Timeout until email is send succesfully.
}

@test:Config {
    dependsOn: ["testGmailAlerts"]
}
function testReadGmail() {
    log:print("gmailClient -> testReadGmail()");
    var response = gmailClient->readMessage(testUserId, sentHtmlMessageId);
    if (response is Message) {
        test:assertEquals(response.id, sentHtmlMessageId, msg = "Read mail with attachment failed");
    } else {
        test:assertFail(msg = response.message());
    }
}