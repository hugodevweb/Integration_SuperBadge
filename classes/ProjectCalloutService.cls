public class ProjectCalloutService {
    //Complete the implementation for business and callout logic
    @InvocableMethod
    public static void PostOpportunityToPMS(List<ID> opportunityIds){
        QueueablePMSCall q = new QueueablePMSCall(opportunityIds);
        System.debug('Enqueing Opportunity Ids: ' + opportunityIds);
        System.enqueueJob(q);
        
    }
    
    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts {
        private Id oppId;
        
        public QueueablePMSCall(List<Id> opportunityIds) {
            System.debug('Constructor done ' + opportunityIds[0]);
            this.oppId = opportunityIds[0];  
        }

        public void execute(QueueableContext context) {

        String Token = ServiceTokens__c.getValues('ProjectServiceToken').Token__c;
        Opportunity opp = [SELECT Id, Name, Account.Name, Amount, CloseDate, StageName 
        FROM Opportunity 
        WHERE Id = :this.oppId];

        String formattedDate = opp.CloseDate.year() + '-' + opp.CloseDate.month() + '-' + opp.CloseDate.day();
        System.debug('Amount ' + opp.Amount);
        Integer amountOpp = opp.Amount.intValue();
        String jsonBody = '{'+
        '"opportunityId": "'+opp.Id+'",'+
        '"opportunityName": "'+opp.Name+'",'+
        '"accountName": "'+opp.Account.Name+'",'+
        '"closeDate": "'+formattedDate+'",'+
        '"amount": '+amountOpp+'}'; 
        System.debug('JSON Body: ' + jsonBody);
        
        HttpRequest req = new HttpRequest();
        
        req.setTimeout(60000);
        req.setEndpoint('callout:ProjectService');
        req.setHeader('token', Token);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setBody(jsonBody);
       
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('Request: ' + req.getBody());
        System.debug('Response code: ' + res.getStatusCode());

        if(res.getStatusCode() == 200){
            opp.StageName = 'Submitted Project';
        }
        else{
            opp.StageName = 'Resubmit Project';
        }
        update opp;
    }
}
}