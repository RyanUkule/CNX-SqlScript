USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetCustomerOrder]    Script Date: 2017/08/15 18:14:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************
Author: Ryan.Han
Create Date: 2017-08-15
***********************/
CREATE PROCEDURE [dbo].[usp_GetCustomerOrder]
(
	@OrderId INT
)
AS
BEGIN
	SELECT
		CustomerOrderId,
		OrderId,
		CustomerId,
		OrderStatusId,
		UpdateDate,
		AveragePrice,
		CompletedAmount,
		[Source]
	FROM CustomerOrder WHERE OrderId = @OrderId
ENd
