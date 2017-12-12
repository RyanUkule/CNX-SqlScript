USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateICO]    Script Date: 2017/11/22 18:13:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_UpdateICO]
@ICOId int,
@name nvarchar(50) = null,
@totalValue decimal(18, 8) = null,
@convertPrice decimal(18,8) = null,
@offerAssetTypeId int = 0, 
@wantAssetTypeId int = 0, 
@startDate datetime = null,
@endDate datetime = null
AS
BEGIN
	IF(EXISTS(SELECT ICOID FROM ICO WHERE ICOId = @ICOId))
	BEGIN
		update ICO set
			[Name] = case when @name is null then [Name] else @name end
			,[TotalValue] = case when @totalValue is null then [TotalValue] else @totalValue end
			,[ConverPrice] = case when @convertPrice is null then [ConverPrice] else @convertPrice end
			,[StartDate] = case when @startDate is null then [StartDate] else @startDate end
			,[EndDate] = case when @endDate is null then [EndDate] else @endDate end
			,[OfferAssetTypeId] = case when @offerAssetTypeId = 0 then [OfferAssetTypeId] else @offerAssetTypeId end
			,[WantAssetTypeId] = case when @wantAssetTypeId = 0 then [WantAssetTypeId] else @wantAssetTypeId end
		FROM [cnx].[dbo].[ICO] with (nolock)
		where ICOId = @ICOId

		SELECT 1
	END
	ELSE
	BEGIN
		SELECT -1
	END
END

