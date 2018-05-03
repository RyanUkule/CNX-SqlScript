USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateAdvanceTransactionHashValue]    Script Date: 2018/03/30 14:56:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[usp_UpdateAdvanceTransactionHashValue]  @AdvanceTransactionId int ,@HashValue nvarchar(200) 
as 
begin
 update AdvancedTransactionV1 set Hash=@HashValue where AdvanceTransactionId=@AdvanceTransactionId
end