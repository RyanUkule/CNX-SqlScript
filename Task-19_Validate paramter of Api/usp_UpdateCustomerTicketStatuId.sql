USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateCustomerTicketStatuId]    Script Date: 2017/10/23 14:23:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_UpdateCustomerTicketStatuId] @CreateBy int, @TicketId int,@TicketStatuId int 
as 
begin
   Update [CustomerTickets] set [TicketStatusId]=@TicketStatuId ,UpdateDate=getDate() where [CreateBy]=@CreateBy and TicketId=@TicketId

   SELECT COUNT(*) FROM [CustomerTickets]
   WHERE [CreateBy]=@CreateBy and TicketId=@TicketId
end
