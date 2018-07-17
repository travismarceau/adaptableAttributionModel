@isTest
public class TestAdaptiveAttribution {

    @isTest
    static void testCampaignInfluenceInsert() {

      // String accId = [SELECT Id FROM Account LIMIT 1].Id;
      // String contactId = [SELECT Id FROM Contact WHERE Account = :accId LIMIT 1].Id;
      // String campaignId = [SELECT CampaignId FROM CampaignMember WHERE LIMIT 1].Id;
      // String modelId = [SELECT ID FROM CampaignInfluenceModel WHERE DeveloperName = 'b2bmaEvenDistributionModel' LIMIT 1].Id;

      Account acct = new Account(Name='Test Account');
      insert acct;

      Opportunity opp = new Opportunity(Name=acct.Name + ' Opportunity',
                                       StageName='Prospecting',
                                       CloseDate=System.today().addMonths(1),
                                       AccountId=acct.Id,
                                       Amount=300000);
      insert opp;

      Contact con = new Contact(Name='Test Contact',
                                AccountId=acct.Id);
      insert opp;

      Campaign camp = new Campaign(Name='Test Campaign',
                                    Active=TRUE,
                                    Multiplier__c=2);
      insert camp;

      String modelId = [SELECT ID FROM CampaignInfluenceModel WHERE DeveloperName = 'b2bmaEvenDistributionModel' LIMIT 1].Id;

      Test.startTest();
      CampaignInfluence newCI = new CampaignInfluence(
          ModelId = modelId,
          OpportunityId = opp.Id,
          Influence = 1,
          ContactId = con.Id,
          CampaignId = camp.Id
        );
      Test.stopTest();

      CampaignInfluence result = [SELECT modelId
                                  FROM CampaignInfluence
                                  WHERE OpportunityId = opp.Id];

      System.assertEquals(modelId, result.modelId, 'CI failed to insert');
    }
}
