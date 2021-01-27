import ballerina/config;
import ballerina/io;
import ballerinax/sfdc;
import ballerinax/googleapis_sheets as sheets4;

const string CREATED = "created";

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
                io:println(caseId);
                var caseRecord = sfdcClient->getRecordById("Case",caseId.toString());
                if(caseRecord is json){
                    createSheetWithNewCase(caseRecord);
                }
                else {
                    io:println(caseRecord);
                }
            }        
        }
        else
        {
            io:println(caseInfo);
        }
    }
}

function createSheetWithNewCase(json case){
    var spreadsheet = gSheetClient->createSpreadsheet(case.CaseNumber.toString());
    if(spreadsheet is sheets4:Spreadsheet){
        var sheet = spreadsheet.getSheetByName("Sheet1");
        if(sheet is sheets4:Sheet){
            map<json> caseMap = <map<json>> case;
            foreach var [key, value] in caseMap.entries() {
                var response = sheet->appendRow([key, value.toString()]);
                io:println(response);
            }
            var rename = sheet->rename("Case Details");
            io:println(rename);    
        }
        else {
            io:println(sheet);
        }
    }
    else {
        io:println(spreadsheet);
    }
}
