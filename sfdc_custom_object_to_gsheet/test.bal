import ballerina/config;
import ballerina/test;
import ballerinax/googleapis_sheets as sheets;

sheets:SpreadsheetConfiguration gsheetConfig = {
    oauth2Config: {
        accessToken: config:getAsString("GS_ACCESS_TOKEN"),
        refreshConfig: {
            clientId: config:getAsString("GS_CLIENT_ID"),
            clientSecret: config:getAsString("GS_CLIENT_SECRET"),
            refreshUrl: sheets:REFRESH_URL,
            refreshToken: config:getAsString("GS_REFRESH_TOKEN")
        }
    }
};

sheets:Client gheetClient = new (gsheetConfig);

@test:Config {}
function testAddObjectToSpreadsheet() {
    json test = {"event":{"createdDate":"2021-01-29T12:58:09.353Z","replayId":42,"type":"created"},"sobject":{"YOM__c":"sdsds","Id":"a005g00002pQw8nAAC","Vehicle_Number__c":"sdsdsd","Name":"dsdsd"}};
    error? res = addObjectToSpreadsheet(test);
}
