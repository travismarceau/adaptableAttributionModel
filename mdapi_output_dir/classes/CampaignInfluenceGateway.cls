/**
 * Class CampaignInfluenceGateway
 *
 * Provides finder methods for accessing data in the Campaign Influence object.
 */
public without sharing class CampaignInfluenceGateway
{
	// return Even Distribution Model ID
	public static String findEvenModelId()
	{
			return [SELECT ID FROM CampaignInfluenceModel WHERE DeveloperName = 'primaryModel' LIMIT 1].Id;
	}

	// return Adaptive Distribution Model ID
	public static String findAdaptiveModelId()
	{
			return [SELECT ID FROM CampaignInfluenceModel WHERE DeveloperName = 'adaptiveDistributionModel' LIMIT 1].Id;
	}

	// return All CampaignInfluence records associated with the Adaptive Model
	public static Map<String,List<CampaignInfluence>> findCampaignMultipliers(String AdaptiveModelId)
	{
		Map<String,List<CampaignInfluence>> oppCampInfMap = new Map<String,List<CampaignInfluence>>();

		for(Opportunity[] opps : [SELECT Id, (SELECT id FROM CampaignInfluences LIMIT 1) FROM Opportunity]) {
			for(Opportunity opp : opps) {
				if(opp.CampaignInfluences.size() > 0) {
					List<CampaignInfluence> cis = [SELECT Id, Campaign.Multiplier__c, CampaignId, Opportunity.Amount, OpportunityId, Influence FROM CampaignInfluence WHERE OpportunityId = :opp.Id AND ModelId = :AdaptiveModelId];
					oppCampInfMap.put(opp.Id,cis);
				}
			}
		}

		return oppCampInfMap;
	}

	// map and return all Opportunities and the total of all associated mulipliers
	public static Map<String,double> findTotalOppMultipliers(String EvenModelId)
	{
		Map<String,double> oppsWithMultipliers = new Map<String,double>();
		AggregateResult[] totalOppMultipliers = [SELECT OpportunityId, SUM(Campaign.Multiplier__c)sumOf FROM CampaignInfluence WHERE ModelId = :EvenModelId GROUP BY OpportunityId];

		for(AggregateResult ar : totalOppMultipliers) {
			oppsWithMultipliers.put((String)ar.get('OpportunityId'),(double)ar.get('sumOf'));
		}
    return oppsWithMultipliers;
	}
}
