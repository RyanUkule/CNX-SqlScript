USE CNX
GO
CREATE PROCEDURE usp_UpdateCampaignCustomerActivityInsertDate
(
	@insertDate datetime,
	@customerId int,
	@campaignId int
)
AS
BEGIN
	UPDATE CampaignCustomerActivity set InsertDate = @insertDate where customerId = @customerId and campaignId = @campaignId
END