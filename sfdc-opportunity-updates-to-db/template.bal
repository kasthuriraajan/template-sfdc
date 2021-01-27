import ballerina/io;
import ballerina/config;
import ballerina/log;
import ballerinax/sfdc;
import ballerinax/mysql;
import ballerina/sql;

sfdc:ListenerConfiguration listenerConfig = {
    username: config:getAsString("SF_USERNAME"),
    password: config:getAsString("SF_PASSWORD")
};

listener sfdc:Listener sfdcEventListener = new (listenerConfig);
mysql:Client mysqlClient = check new (user = config:getAsString("DB_USER"), password = config:getAsString("DB_PWD"));

@sfdc:ServiceConfig {topic: config:getAsString("SF_OPPORTUNITY_TOPIC")}
service on sfdcEventListener {
    remote function onEvent(json op) {
        io:StringReader sr = new (op.toJsonString());
        json|error opportunity = sr.readJson();
        if (opportunity is json) {
            string accountId = opportunity.sobject.AccountId.toString();
            sql:Error? result = addOpportunityToDB(opportunity);
            if (result is error) {
                log:printError(result.message());
            }
        }
    }
}

# Store oppertunity into database
# 
# + opportunity - Opportunities in json
# + return - Sql error on error 
function addOpportunityToDB(json opportunity) returns sql:Error? {
    string stageName = opportunity.sobject.StageName.toString();
    string accountId = opportunity.sobject.AccountId.toString();
    string id = opportunity.sobject.Id.toString();
    string name = opportunity.sobject.Name.toString();

    log:print(id + " : " + accountId + " : " + name + " : " + stageName);
    sql:ParameterizedQuery insertQuery = `INSERT INTO ESC_SFDC_TO_DB.Opportunity (Id, AccountId, Name, Description) 
            VALUES (${
    id}, ${accountId}, ${name}, ${stageName})`;
    sql:ExecutionResult result = check mysqlClient->execute(insertQuery);
}
