USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_AddAssetBalanceForCustomer]    Script Date: 2017/10/26 13:50:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_AddAssetBalanceForCustomer]
(
	@AssetTypeId int
)
AS
BEGIN
	--Add balance for each customer
	INSERT INTO AssetBalance(CustomerId, AssetTypeId, Balance, FrozenBalance, UpdateDate, InsertDate, SaveDate, Locked, [Hash])
	SELECT CustomerId, @AssetTypeId, 0, 0, getdate(), getdate(), getdate(), 0, ''
	FROM AssetBalance
	WHERE CustomerId not in (SELECT CustomerId FROM AssetBalance WITH(NOLOCK) WHERE AssetTypeId = @AssetTypeId)
	GROUP BY customerid

END

