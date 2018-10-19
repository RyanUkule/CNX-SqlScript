CREATE PROCEDURE usp_AddCampaignCustomerActivity
(
	@customerId int,
	@campaignId int,
	@completeDate datetime
)
AS
BEGIN
	INSERT INTO CampaignCustomerActivity ([CustomerId], [CampaignId], [InsertDate]) 
	VALUES(@customerId, @campaignId, @completeDate)
END