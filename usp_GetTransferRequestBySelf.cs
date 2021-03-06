USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetTransferRequestBySelf]    Script Date: 2018/02/02 11:11:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Percy
-- Email:       peng.xingxing@itr.cn
-- Create date: 
-- Modify date: 2016-12-21 14:33:56
-- Description:	usp_GetTransferRequestBySelf
-- ============================================= 
ALTER PROCEDURE [dbo].[usp_GetTransferRequestBySelf]  
@requestId INT,  
@requestTypeId INT,  
@userName nvarchar(100),  
@phone varchar(20),  
@bankName nvarchar(50),  
@accountnumber nvarchar(250),  
@expectAmount decimal(18, 2),  
@receivedAmount decimal(18, 2),  
@requestStatusId int,  
@bankTransactionStatusId int,  
@insertStartDate datetime,  
@insertEndDate datetime,  
@updateStartDate datetime,  
@updateEndDate datetime,  
@skip int,  
@take int  
AS  
BEGIN  
 declare @countcurrent int, @offset int  
  
 select @countcurrent = count(*)   
 from   
 TransferRequest r with (nolock)  
 left join Customer c with (nolock) on r.CustomerId = c.CustomerId  
 left join BankTransaction bt with (nolock) on r.BankTransactionId = bt.BankTransactionId  
 where  
 r.RequestId = case when @requestId is null then r.RequestId else @requestId end  
 and r.RequestTypeId = case when @requestTypeId is null then r.RequestTypeId else @requestTypeId end  
 and c.UserName = case when @userName is null then c.UserName else @userName end  
 and (c.Mobile = case when @phone is null then c.Mobile else @phone end OR (c.Mobile IS NULL AND @phone IS NULL))
 and (bt.TransactionBank is null or bt.TransactionBank = case when @bankName is null then bt.TransactionBank else @bankName end)  
 and (bt.TransactionAccountNumber is null or bt.TransactionAccountNumber = case when @accountnumber is null then bt.TransactionAccountNumber else @accountnumber end)  
 and r.Amount = case when @expectAmount is null then r.Amount else @expectAmount end  
 and r.RequestStatusId = case when @requestStatusId is null then r.RequestStatusId else @requestStatusId end  
 and (bt.TransactionAmount is null or bt.TransactionAmount = case when @receivedAmount is null then bt.TransactionAmount else @receivedAmount end)  
 and (bt.TransactionStatusId is null or bt.TransactionStatusId = case when @bankTransactionStatusId is null then bt.TransactionStatusId else @bankTransactionStatusId end)  
 and r.InsertDate >= case when @insertStartDate is null then r.InsertDate else @insertStartDate end  
 and r.InsertDate <= case when @insertEndDate is null then r.InsertDate else @insertEndDate end  
 and r.UpdateDate >= case when @updateStartDate is null then r.UpdateDate else @updateStartDate end  
 and r.UpdateDate <= case when @updateEndDate is null then r.UpdateDate else @updateEndDate end  
  
 set @offset = case when @countcurrent < (@skip + @take) then (@countcurrent-@skip) else @take end  
  
 select * from   
 (  
  select top (@offset) * from   
  (  
   select top (@take + @skip)   
   r.RequestId RequestId  
   ,rt.Name RequestType  
   ,c.UserName Username  
   ,d.RealName RealName  
   ,c.Mobile Mobile  
   ,at.Symbol + ' ' + Convert(varchar,r.Amount) Amount  
   ,r.Commision Commission  
   ,rs.Name RequestStatus  
   ,r.UpdateDate UpdateDate  
   ,r.InsertDate InsertDate  
   ,ac.UserName ApprovedName  
   ,b.BankName BankName  
   ,b.BankBranch BankBranch
   ,b.BankAccountName AccountName  
   ,b.BankAccountNumber AccountNumber  
   ,bt.BankTransactionId  
   ,c.CustomerId CustomerId  
   ,r.ApprovedHash ApproveHash
   ,r.ConfirmationCode
   ,case when (r.RequestTypeId in (2, 9, 11, 13, 17) AND r.RequestStatusId=3 AND r.ConfirmationCode IS NULL AND r.RequestId > 3438) then 'True' else 'False' end Repair
   from   
   TransferRequest r with (nolock)  
   left join RequestType_lkp rt with (nolock) on r.RequestTypeId = rt.RequestTypeId  
   left join Customer c with (nolock) on r.CustomerId = c.CustomerId  
   left join VerificationDocument d with (nolock) on r.CustomerId = d.CustomerId  
   left join AssetType_lkp at with (nolock) on r.AssetTypeId = at.AssetTypeId  
   left join RequestStatus_lkp rs with (nolock) on r.RequestStatusId = rs.RequestStatusId  
   left join Customer ac with (nolock) on r.ApprovedCustomerId = ac.CustomerId  
   left join BankAccountInfo b with (nolock) on r.WithdrawBankAccountId = b.BankAccountInfoId  
   left join BankTransaction bt with (nolock) on r.BankTransactionId = bt.BankTransactionId  
   where  
   r.RequestId = case when @requestId is null then r.RequestId else @requestId end  
   and r.RequestTypeId = case when @requestTypeId is null then r.RequestTypeId else @requestTypeId end  
   and c.UserName = case when @userName is null then c.UserName else @userName end  
   and (c.Mobile = case when @phone is null then c.Mobile else @phone end OR (c.Mobile IS NULL AND @phone IS NULL))
   and (bt.TransactionBank is null or bt.TransactionBank = case when @bankName is null then bt.TransactionBank else @bankName end)  
   and (bt.TransactionAccountNumber is null or bt.TransactionAccountNumber = case when @accountnumber is null then bt.TransactionAccountNumber else @accountnumber end)  
   and r.Amount = case when @expectAmount is null then r.Amount else @expectAmount end  
   and r.RequestStatusId = case when @requestStatusId is null then r.RequestStatusId else @requestStatusId end  
   and (bt.TransactionAmount is null or bt.TransactionAmount = case when @receivedAmount is null then bt.TransactionAmount else @receivedAmount end)  
   and (bt.TransactionStatusId is null or bt.TransactionStatusId = case when @bankTransactionStatusId is null then bt.TransactionStatusId else @bankTransactionStatusId end)  
   and r.InsertDate >= case when @insertStartDate is null then r.InsertDate else @insertStartDate end  
   and r.InsertDate <= case when @insertEndDate is null then r.InsertDate else @insertEndDate end  
   and r.UpdateDate >= case when @updateStartDate is null then r.UpdateDate else @updateStartDate end  
   and r.UpdateDate <= case when @updateEndDate is null then r.UpdateDate else @updateEndDate end  
   Order By InsertDate desc  
  )  
  a order by InsertDate asc  
 )  
 b order by InsertDate desc   
  
 select @countcurrent  
END  




