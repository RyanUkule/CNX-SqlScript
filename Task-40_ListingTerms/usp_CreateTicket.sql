USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateTicket]    Script Date: 2018/06/04 17:35:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
ALTER PROCEDURE [dbo].[usp_CreateTicket]  
@CreateBy int,  
@RelatedCustomerId int,  
@Subject nvarchar(500),  
@Category nvarchar(500),  
@Content nvarchar(max),  
@AssginTo int = null,  
@SourceId int,  
@UrgencyId int,  
@TicketStatusId int,  
@DocumentName nvarchar(100),  
@DocumentDescription nvarchar(300)  
AS  
BEGIN  
 Declare @TicksId int   
  
 Insert into CustomerTickets (CreateBy,RelatedCustomerId,[Subject],Category,TicketContent,AssignTo,CustomerTicketSourceId,CustomerTickerUrgencyId,CreateDate,UpdateDate,TicketStatusId)  
  values(@CreateBy,@RelatedCustomerId,@Subject,@Category,@Content,@AssginTo,@SourceId,@UrgencyId,GETDATE(),GetDate(),@TicketStatusId)  
  
 Select @TicksId=SCOPE_IDENTITY()  
  
 if(@DocumentDescription is not null or @DocumentName is not null)  
 begin  
  if(@DocumentDescription is null)  
  begin  
   set @DocumentDescription = ''  
  end
  IF(@DocumentName IS NULL)  
  BEGIN
	SET @DocumentName=''
  END
  Insert into [CustomerTicketDocument]([CustomerTicketId],[CustomerTicketStatusId],[CustomerTickerAssginTo],[Comment],[Document],[CreateBy],[CreateDate])  
   values(@TicksId,@TicketStatusId,@AssginTo,@DocumentDescription,@DocumentName,@CreateBy,getDate())  
 end  
END  
  