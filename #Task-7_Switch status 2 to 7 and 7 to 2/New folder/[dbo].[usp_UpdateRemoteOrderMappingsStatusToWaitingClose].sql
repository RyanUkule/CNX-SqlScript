USE [cnx]
GO

DROP PROC [dbo].[usp_UpdateRemoteOrderMappingsStatusToActiveOrSuspend]

GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateRemoteOrderMappingsStatusToWaitingClose]    Script Date: 2017/06/01 17:21:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_UpdateRemoteOrderMappingsStatusToWaitingClose]
(
	@suspendOrderIds XML,
	@message NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @t_suspendOrderId TABLE
	(
		OrderId INT
	);

	INSERT INTO @t_suspendOrderId(OrderId)
	SELECT X.C.value('Id[1]', 'INT') AS OrderId
	FROM @suspendOrderIds.nodes('Root/Parameter') AS X(C)

	UPDATE RemoteOrderMappings SET [RemoteOrderMappingStatusId] = 12, [Message]=@message, UpdateDate=GETDATE()
	WHERE OrderId in (SELECT OrderId FROM @t_suspendOrderId) and [RemoteOrderMappingStatusId]  not in  (9,11,13,14,15,17)
END