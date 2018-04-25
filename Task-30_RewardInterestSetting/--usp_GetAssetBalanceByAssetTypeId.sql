CREATE PROCEDURE usp_GetAssetBalanceByAssetTypeId
(
	@assetTypeId int
)
AS
BEGIN
	SELECT	
		   a.[CustomerId]
		  ,[AssetTypeId]
		  ,[Balance]
		  ,[FrozenBalance]
	FROM AssetBalance a
	inner join customer c with(nolock) on a.CustomerId = c.CustomerId
	WHERE AssetTypeId = 15
		and Balance > 0
		and a.CustomerId <> 2
		and c.IsTestAccount = 0
END