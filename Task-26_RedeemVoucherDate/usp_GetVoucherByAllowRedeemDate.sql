use CNX
GO
CREATE PROCEDURE usp_GetVoucherByAllowRedeemDate
(
	@BeginDate datetime = null,
	@EndDate datetime = null
)
AS
BEGIN
	SELECT 
		VoucherId,
		RedemptionCodeHash,
		Value,
		IssuedByCustomerId,
		IsRedeemed,
		RedeemedByCustomerId,
		IsCanceled,
		UpdateDate,
		InsertDate,
		SaveDate,
		AssetTypeId,
		VoucherTransactionId,
		Note,
		CampaignId,
		AllowRedeemDate
	FROM voucher
	WHERE AllowRedeemDate >= @BeginDate and AllowRedeemDate < @EndDate
END