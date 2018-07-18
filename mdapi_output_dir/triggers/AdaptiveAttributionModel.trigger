trigger AdaptiveAttributionModel on CampaignInfluence (after delete, after insert, after update, before delete, before insert, before update) {
  TriggerFactory.createHandler(CampaignInfluence.sObjectType);
}
