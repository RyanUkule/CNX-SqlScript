USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadRecentOrderV2]    Script Date: 2019/06/20 16:15:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_LoadRecentOrderV2]
@CustomerId int,
@AssetTypeId int = null,
@AssetTypeId2 int = null,
@OrderType varchar(10),
@OrderStatusId int,
@UpDatedate nvarchar(50) = null,
@Skip int 
AS
BEGIN
	declare @startrow int,@RowCount int
	set @RowCount = 30
	set @startrow = (@Skip-1) * @RowCount

	if(@startrow < 0)
	begin
		set @startrow = 0
	end

	declare @script varchar(8000) =
	'SELECT 
	co.OrderId,
    co.OrderStatusId,
	co.CompletedAmount,
	o.Price,
	o.Quantity,
	o.OrderTypeId,
	co.UpdateDate,
	o.OrderTypeId,
	o.OrderClassId,
	o.offerAssetTypeId,
	o.wantAssetTypeId,
	o.MarketOrder
	from
	CustomerOrder co with(nolock) 
	left join OrderBook o with(nolock) on co.OrderId = o.OrderId
	where co.customerId = ' +  CAST(@CustomerId as varchar(10))



	if(@OrderStatusId = 111)
	begin
		set @script = @script + ' and co.OrderStatusId in (3,4,5,11)'
	end
	else if(@OrderStatusId = 110)
	begin
		set @script = @script + ' and (co.OrderStatusId in(2,3,7,12) or (co.OrderstatusId in(4,5) and DateDiff(ss,co.UpdateDate,getDate())<=30  ))'
	end
	else
	begin
		set @script = @script + ' and co.OrderStatusId = ' +  CAST(@OrderStatusId as varchar(10))
	end

	if(@AssetTypeId is not null and @AssetTypeId2 is not null)
	begin
		set @script = @script + ' and ((o.WantAssetTypeId = ' +  CAST(@AssetTypeId as varchar(2)) + ' and o.offerAssetTypeId = ' + CAST(@AssetTypeId2 as varchar(2)) + ')'
		set @script = @script + ' or (o.WantAssetTypeId = ' + CAST(@AssetTypeId2 as varchar(2)) + ' and o.offerAssetTypeId = ' + CAST(@AssetTypeId as varchar(2)) + '))'
		
	end
	else if(@AssetTypeId is not null)
	begin
		set @script = @script + ' and (o.WantAssetTypeId = ' + CAST(@AssetTypeId as varchar(2)) + 'or o.offerAssetTypeId = ' + CAST(@AssetTypeId as varchar(2)) +')'
	end
	else if(@AssetTypeId2 is not null)
	begin
		set @script = @script + ' and (o.WantAssetTypeId = ' + CAST(@AssetTypeId2 as varchar(2)) + 'or o.offerAssetTypeId = ' + CAST(@AssetTypeId2 as varchar(2)) +')'
	end

	if(@OrderType is not null)
	begin
	   if(@OrderType = 'TR')
	   begin
			set @script = @script + ' and o.orderclassId = 4'
	   end
	   else if(@OrderType = 'SL')
	   begin
			set @script = @script + ' and o.orderclassId =3'
	   end
	   else if(@OrderType = 'TP')
	   begin
		    set @script = @script + ' and o.orderclassId =2'
	   end
	   else if(@OrderType = 'M')
	   begin
			set @script = @script + ' and o.MarketOrder = 1'
	   end
	   else if(@OrderType = 'Buy')
	   begin
			set @script = @script + ' and o.OrderTypeId = 1'
	   end
	   else if(@OrderType = 'Sell')
	   begin
			set @script = @script + ' and o.OrderTypeId = 2'
	   end
	end

	if(@UpDatedate is not null and @UpDatedate <> '')
	begin
		set @script = @script + 'and co.UpdateDate >' + '''' + @UpDatedate+ ''''
	end
	else
	begin
		set @script = @script  +
		' order by o.UpdateDate desc
		OFFSET ' + CAST(@startrow as varchar(10))+ ' ROW
		FETCH NEXT '+ CAST(@RowCount as varchar(10)) +' ROW ONLY'
	end

	exec (@script)

END
