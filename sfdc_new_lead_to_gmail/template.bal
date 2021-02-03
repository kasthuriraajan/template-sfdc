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
            }
        }
    }
}

function sendGmailAlert(json newLead) returns @tainted error?{

    log:print("New Lead : " + newLead.toString());
    
    gmail:MessageRequest messageRequest = {};
    messageRequest.recipient = newLead.sobject.Email.toString();
    messageRequest.sender = config:getAsString("G_SENDER_EMAIL");
    messageRequest.cc = config:getAsString("G_CC_EMAIL");
    messageRequest.subject = "NEW LEAD from : " +newLead.sobject.Company.toString();
    messageRequest.messageBody = "<h1> Welcome </h1> <br/> <h2> Name : " +newLead.sobject.Name.toString()+ "</h2>";
    messageRequest.contentType = gmail:TEXT_HTML;

    //Send the message.
    var sendMessageResponse = gmailClient->sendMessage(G_USER_ID, messageRequest); 
    log:print(sendMessageResponse.toString());          
}