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
import ballerina/config;
import ballerina/log;
import ballerinax/sfdc;
import ballerinax/googleapis_gmail as gmail;

gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        accessToken: config:getAsString("G_ACCESS_TOKEN"),
        refreshConfig: {
            refreshUrl: config:getAsString("G_REFRESH_URL"),
            refreshToken: config:getAsString("G_REFRESH_TOKEN"),
            clientId: config:getAsString("G_CLIENT_ID"),
            clientSecret: config:getAsString("G_CLIENT_SECRET")
        }
    }
};

sfdc:ListenerConfiguration listenerConfig = {
    username: config:getAsString("SF_USERNAME"),
    password: config:getAsString("SF_PASSWORD")
};

listener sfdc:Listener sfdcEventListener = new (listenerConfig);
gmail:Client gmailClient = new (gmailConfig);

@sfdc:ServiceConfig {
    topic: TOPIC_PREFIX + config:getAsString("SF_BROADCAST_TOPIC")
}
service on sfdcEventListener {
    remote function onEvent(json op) {
        io:StringReader sr = new(op.toJsonString());
        json|error newLead = sr.readJson();
        if ((newLead is json) && (TYPE_CREATED.equalsIgnoreCaseAscii(newLead.event.'type.toString()))){
            var result = sendGmailAlert(newLead);
            if (result is error) {
                log:printError(result.message());
            } else {
                log:print(result.toString());
            }
        }
    }
}

function sendGmailAlert(json newLead) returns @tainted [string, string] | error?{

    log:print("New Lead : " + newLead.toString());

    gmail:MessageRequest messageRequest = {};
    messageRequest.recipient = newLead.sobject.Email.toString();
    messageRequest.sender = config:getAsString("G_SENDER_EMAIL");
    messageRequest.cc = config:getAsString("G_CC_EMAIL");
    messageRequest.subject = "NEW LEAD from : " +newLead.sobject.Company.toString();
    messageRequest.messageBody = "<h1> Welcome </h1> <br/>"+
                                 "<h2> Name : " +newLead.sobject.Name.toString()+ "</h2> <br/>"+
                                 "<h2> Company : " +newLead.sobject.Company.toString()+ "</h2> <br/>"+
                                 "<h2> Phone : " +newLead.sobject.Phone.toString()+ "</h2> <br/>"+
                                 "<h2> Lead Status : " +newLead.sobject.Status.toString()+ "</h2> <br/>"+
                                 "<h3> Thank you </h3>";
    messageRequest.contentType = gmail:TEXT_HTML;

    //Send the message.
    var sendMessageResponse = gmailClient->sendMessage(G_USER_ID, messageRequest); 
    return sendMessageResponse;          
}