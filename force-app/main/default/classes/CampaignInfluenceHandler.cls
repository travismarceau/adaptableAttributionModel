/**
 * Class AccountHandler
 *
 * Trigger Handler for the Account SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public with sharing class CampaignInfluenceHandler implements ITrigger
{
	// lists of campaign influence records to be added and multipliers
  List<CampaignInfluence> campInfs = new List<CampaignInfluence>();
  Map<String,List<CampaignInfluence>> campMultipliers = new Map<String,List<CampaignInfluence>>();

  // empty AggregateResult for multiplier totals
  Map<String,double> oppsWithMultipliers = new Map<String,double>();
  double totalOfMultipliers = 0;

  // id of the required attribution models
  String EvenModelId = ''; // = [SELECT ID FROM CampaignInfluenceModel WHERE DeveloperName = 'b2bmaEvenDistributionModel' LIMIT 1].Id;
  String AdaptiveModelId = ''; // = [SELECT ID FROM CampaignInfluenceModel WHERE DeveloperName = 'adaptiveDistributionModel' LIMIT 1].Id;

	// Constructor
	public CampaignInfluenceHandler()
	{
	}

	/**
	 * bulkBefore
	 *
	 * This method is called prior to execution of a BEFORE trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	public void bulkBefore()
	{
		// If this an insert or update trigger Cache a list of CampaignInfluence Records
		if (Trigger.isInsert || Trigger.isUpdate)
		{
			// pre load all the in use records passed to this trigger
			// m_inUseIds = CampaignInfluenceGateway.findCampaignInfluenceIdsInUse(Trigger.oldMap.keySet());
      EvenModelId = CampaignInfluenceGateway.findEvenModelId();
      AdaptiveModelId = CampaignInfluenceGateway.findAdaptiveModelId();

      // fetch total sum of multipliers across all campaigns for related Opp
      oppsWithMultipliers = CampaignInfluenceGateway.findTotalOppMultipliers(EvenModelId);
      campMultipliers = CampaignInfluenceGateway.findCampaignMultipliers(AdaptiveModelId);
    }
	}

	public void bulkAfter()
	{
	}

	public void beforeInsert(SObject so)
	{
	}

	public void beforeUpdate(SObject oldSo, SObject so)
	{
	}

	public void beforeDelete(SObject so)
	{
	}

	public void afterInsert(SObject so)
	{
    CampaignInfluence ci = (CampaignInfluence)so;
    if((String)ci.ModelId != EvenModelID) return;
    if(ci.Campaign.Multiplier__c == null) return;

    totalOfMultipliers = oppsWithMultipliers.get(ci.OpportunityId);

    if(totalOfMultipliers == 0) return;
    System.debug(totalOfMultipliers);

    // create empty record
    CampaignInfluence newCI = new CampaignInfluence();

    // add newCI's values
    newCI.ModelId = AdaptiveModelId;
    newCI.OpportunityId = ci.OpportunityId;
    newCI.Influence = (ci.Campaign.Multiplier__c / totalOfMultipliers) * 100;
    newCi.ContactID = ci.ContactId;
    newCi.CampaignId = ci.CampaignId;

    // add new record to Campaign Influence records to be updated
    campInfs.add(newCI);

    // update all of the other Campaign Influence records
    for(CampaignInfluence cia : campMultipliers.get(ci.OpportunityId)) {
      cia.Influence = (cia.Campaign.Multiplier__c / totalOfMultipliers) * 100;
      campInfs.add(cia);
    }
	}

	public void afterUpdate(SObject oldSo, SObject so)
	{
	}

	public void afterDelete(SObject so)
	{
	}

	/**
	 * andFinally
	 *
	 * This method is called once all records have been processed by the trigger. Use this
	 * method to accomplish any final operations such as creation or updates of other records.
	 */
	public void andFinally()
	{
		// insert any audit records
    if(!campInfs.isEmpty()) {
      upsert campInfs;
    }
	}
}
