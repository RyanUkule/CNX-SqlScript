USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateRemoteOrderMappingsRemoteOrderInfoAndStatus]    Script Date: 2017/07/14 14:22:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  Procedure  [dbo].[usp_UpdateRemoteOrderMappingsRemoteOrderInfoAndStatus]  
@orderid int,
@remoteorderid nvarchar(200), 
@averageprice decimal(20,8),
@totalamount decimal(20,8),
@message nvarchar(max) = null
as 
begin 
	declare @RequestQuantity decimal(20,8)
	if(@orderid is not null and @remoteorderid is not null)
	begin
		select   @RequestQuantity= Quantity from RemoteOrderMappings with (nolock) where OrderId=@orderid and RemoteOrderId=@remoteorderid
		if(@RequestQuantity=@totalamount)
		begin
			update RemoteOrderMappings set [RemoteExecutePrice]=@averageprice,[RemoteExecuteQuantity]=@totalamount,[RemoteOrderMappingStatusId] = 2, UpdateDate=getdate(),[Message] = @message
			where OrderId=@orderid and RemoteOrderId=@remoteorderid
		end
		else
		begin
			update RemoteOrderMappings set [RemoteExecutePrice]=@averageprice,[RemoteExecuteQuantity]=@totalamount, UpdateDate=getdate(),[Message] = @message
			where OrderId=@orderid and RemoteOrderId=@remoteorderid
		end
	end
end
