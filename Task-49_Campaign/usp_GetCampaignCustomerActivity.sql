CREATE PROCEDURE usp_GetCampaignCustomerActivity
(
	@customerId int
)
AS
BEGIN
	SELECT [CampaignCustomerActivityId]
		,[CustomerId]
		,[CampaignId]
		,[InsertDate]
	FROM CampaignCustomerActivity
	WHERE CustomerId = @customerId
END