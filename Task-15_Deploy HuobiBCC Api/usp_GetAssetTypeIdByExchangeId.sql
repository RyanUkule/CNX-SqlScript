USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetAssetTypeIdByExchangeId]    Script Date: 2017/08/31 14:14:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************
Modified by: Ryan.Han
Modified Date: 2017-08-31
***************************/
ALTER PROCEDURE [dbo].[usp_GetAssetTypeIdByExchangeId]
(
	@exchangeId int
)
AS
BEGIN
	SELECT 
		OrderTypeId,
		WantAssetTypeId,
		OfferAssetTypeId
	FROM RemoteOrderMappings WITH (NOLOCK) 
	WHERE RemoteExchangeId = @exchangeId AND RemoteOrderMappingStatusId = 8
	group by OrderTypeId,WantAssetTypeId,OfferAssetTypeId
END