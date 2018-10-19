USE CNX
GO
CREATE PROCEDURE usp_GetOldCustomerThatNeedInitializeCampaign
AS
BEGIN
	SELECT b.CampaignId, a.CustomerId, a.InsertDate, b.StartDate 
	FROM Customer a 
	INNER JOIN Campaign b ON a.InsertDate < b.StartDate
	WHERE b.Active = 1 
	ORDER BY a.CustomerId, CampaignId
END