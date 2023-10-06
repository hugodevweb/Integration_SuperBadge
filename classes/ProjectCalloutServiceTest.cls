@isTest
public class ProjectCalloutServiceTest {
  
  @testSetup
  static void makeData() {
    ServiceTokens__c token = new ServiceTokens__c();
    token.Name = 'ProjectServiceToken';
    token.Token__c = '9146bde6-c922-4563-8e5e-1d49b5f4f640';
    insert token;
    
    Account a = new Account();
    a.Name = 'Test Account';
    insert a;
    
    Opportunity o = new Opportunity();
    o.Name = 'Test Opportunity';
    o.AccountId = a.Id;
    o.StageName = 'Negotiation/Review';
    o.CloseDate = Date.today();
    o.Type = 'New Project';
    o.Amount = 10000;
    insert o;
  }
  
  // Test method to cover the positive scenario
  @isTest
  static void testSuccessCallout() {
    Opportunity o = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
    System.debug('Opportunity: ' + o);
    List<Id> opportunityIds = new List<Id>{o.Id};
    System.debug('Opportunity Ids: ' + opportunityIds);
    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());

    Test.startTest();
    ProjectCalloutService.PostOpportunityToPMS(opportunityIds);
    Test.stopTest();

    Opportunity updatedOpportunity = [SELECT StageName FROM Opportunity WHERE Id = :o.Id];
    
    System.assertEquals('Submitted Project', updatedOpportunity.StageName);
  }
  
  @isTest
  static void testFailCallout() {
    Opportunity o = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
    System.debug('Opportunity: ' + o);
    List<Id> opportunityIds = new List<Id>{o.Id};
    System.debug('Opportunity Ids: ' + opportunityIds);
    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());

    Test.startTest();
    ProjectCalloutService.PostOpportunityToPMS(opportunityIds);
    Test.stopTest();

    Opportunity updatedOpportunity = [SELECT StageName FROM Opportunity WHERE Id = :o.Id];
    
    System.assertEquals('Resubmit Project', updatedOpportunity.StageName);
  }
  }