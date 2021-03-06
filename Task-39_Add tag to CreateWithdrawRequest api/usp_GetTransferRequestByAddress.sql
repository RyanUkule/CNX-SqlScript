USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetTransferRequestByAddress]    Script Date: 2018/05/31 14:04:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:		Percy  
-- Email:       peng.xingxing@itr.cn  
-- Create date: 2017-4-28 12:48:59  
-- Modify date: 2017-4-28 12:49:07
-- Description: usp_GetTransferRequestByAddress
-- =============================================  
ALTER PROCEDURE [dbo].[usp_GetTransferRequestByAddress]
	@customerId INT = null,
	@assetTypeId INT = null,
	@addressId NVARCHAR(MAX) = null,
	@tag NVARCHAR(30) = null
AS
BEGIN
	SELECT TOP 10 tr.* 
	FROM TransferRequest tr WITH(NOLOCK) LEFT JOIN BitcoinAddress ba WITH(NOLOCK) ON tr.BitcoinAddressId=ba.BitcoinAddressId
	WHERE ba.AssetTypeId=@assetTypeId AND ba.CustomerId=@customerId AND ba.AddressId=@addressId AND ba.Tag = @tag and IsDeposit = 0 and tr.RequestStatusId =3
	ORDER BY 1 DESC
END