USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateRemoteOrderMappingsRemoteOrderIdAndStatus]    Script Date: 2017/06/29 16:18:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_UpdateRemoteOrderMappingsRemoteOrderIdAndStatus]
@orderid bigint,
@remoteorderid bigint,
@remotestatusid int,
@message nvarchar(max) = null
AS
BEGIN
   if(@remoteorderid is not null)
   begin
		if(@remotestatusid = 8)
		begin
			Update RemoteOrderMappings set [RemoteOrderId] = @remoteorderid
				  ,[RemoteOrderMappingStatusId] = @remotestatusid 
				  ,UpdateDate=getdate()
				  ,[Message] = case when @message is null then [Message] else @message end
			where OrderId = @orderid 
				and [RemoteOrderMappingStatusId] = 7
		end
		else
		begin
			Update RemoteOrderMappings set [RemoteOrderId] = @remoteorderid
				  ,[RemoteOrderMappingStatusId] = @remotestatusid 
				  ,UpdateDate=getdate()
				  ,[Message] = case when @message is null then [Message] else @message end
			where OrderId = @orderid 
				and [RemoteOrderMappingStatusId]  not in (9,11,13,14,15,17)
		end
   end
   else 
   begin
      Update RemoteOrderMappings set [RemoteOrderMappingStatusId] = @remotestatusid ,UpdateDate=getdate(),
	  [Message] = case when @message is null then [Message] else @message end   
	  where OrderId = @orderid and [RemoteOrderMappingStatusId]  not in  (9,11,13,14,15,17)
   end

   select @@ROWCOUNT;
END