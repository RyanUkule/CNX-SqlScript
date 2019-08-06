USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateRemoteOrderMappings]    Script Date: 2019/08/06 18:45:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Percy
-- Email:       peng.xingxing@itr.cn
-- Create date: 2017-2-9 11:04:32
-- Modify date: 2017-2-9 11:04:32
-- Description:	usp_CreateRemoteOrderMappings
-- =============================================
ALTER PROCEDURE [dbo].[usp_CreateRemoteOrderMappings] 
	@OrderId BIGINT,
	@ExecutePrice DECIMAL(18, 8),
	@Quantity DECIMAL(18, 8),
	@RemoteExchangeId INT=NULL,
	@RemoteOrderId BIGINT=NULL,
	@RemoteExecutePrice DECIMAL(18, 8)=NULL,
	@RemoteExecuteQuantity DECIMAL(18, 8)=NULL,
	@OrderTypeId INT,
	@OfferAssetTypeId INT,
	@WantAssetTypeId INT,
	@RemoteOrderMappingStatusId INT=null,
	@Message NVARCHAR(2000)=NULL,
	@InsertDate DATETIME,
	@UpdateDate DATETIME
AS
BEGIN
	declare @assetTypeId int, @symbol nvarchar(20), @wantAssetTypeName nvarchar(10), @offerAssetTypeName nvarchar(10), @result int

	select @wantAssetTypeName = Name from AssetType_lkp with (nolock) where AssetTypeId = @WantAssetTypeId
	select @offerAssetTypeName = Name from AssetType_lkp with (nolock) where AssetTypeId = @OfferAssetTypeId

	if(@OrderTypeId =1)
	begin
		set @assetTypeId = @WantAssetTypeId
		set @symbol = @offerAssetTypeName + '_' + @wantAssetTypeName
	end
	else
	begin
		set @assetTypeId = @OfferAssetTypeId
		set @symbol = @wantAssetTypeName + '_' + @offerAssetTypeName
	end

	----BTC交易ETH是特例,orderTypeId 要切换
	--if((@WantAssetTypeId = 2 and @OfferAssetTypeId = 5) or (@WantAssetTypeId = 5 and @OfferAssetTypeId = 2))
	--begin
	--	set @OrderTypeId = case when @OrderTypeId = 1 then 2 else 1 end
	--	set @ExecutePrice = round(1 / @ExecutePrice, 5)
	--end

	insert into [Log] 
	select getdate(), 0, '', '', @wantAssetTypeName + ',' + @offerAssetTypeName + ',' + convert(nvarchar(20), @OrderTypeId), null, 'CreateMappings', @OrderId
	insert into [Log] 
	select getdate(), 0, '', '', @symbol, null, 'CreateMappings', @OrderId

	if exists(select * from ExchangeSetting where Active = 1 and ExchangeId <> 16 and Symbol = @symbol) or @symbol = 'USD_UCAD'
	begin
		INSERT INTO RemoteOrderMappings(OrderId,ExecutePrice,Quantity,RemoteExchangeId,RemoteOrderId,RemoteExecutePrice,RemoteExecuteQuantity,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,RemoteOrderMappingStatusId,[Message],InsertDate,UpdateDate) 
		VALUES (@OrderId,@ExecutePrice,@Quantity,@RemoteExchangeId,@RemoteOrderId,@RemoteExecutePrice,@RemoteExecuteQuantity,@OrderTypeId,@OfferAssetTypeId,@WantAssetTypeId,@RemoteOrderMappingStatusId,@Message,@InsertDate,@UpdateDate);
		SELECT @result = SCOPE_IDENTITY();

		insert into [Log] 
		select getdate(), 0, '', '', @symbol + ', ' + CONVERT(nvarchar(10), @result), null, 'CreateMappings', @OrderId
		
		select * from RemoteOrderMappings with(nolock) where RemoteOrderMappingsId = @result
	end
 END