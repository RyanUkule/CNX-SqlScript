USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetAssetTypeIdByExchangeId]    Script Date: 2017/08/31 14:14:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_GetAssetTypeIdByExchangeId]
(
	@exchangeId int
)
AS
BEGIN
	SELECT AssetTypeId
	FROM
		(SELECT 
			   CASE OrderTypeId 
					WHEN 1 THEN WantAssetTypeId
					WHEN 2 THEN OfferAssetTypeId END AS AssetTypeId 
		FROM RemoteOrderMappings WITH (NOLOCK) WHERE RemoteExchangeId = @exchangeId) OrderMappings
	GROUP BY AssetTypeId
END