USE [cnx]
GO
/****** Object:  Trigger [dbo].[trg_OrderstatusUpdate]    Script Date: 2017/08/23 14:41:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER TRIGGER [dbo].[trg_OrderstatusUpdate]
   on  [dbo].[OrderBook]
   FOR Update
AS 
BEGIN
	declare @TargetstatusId int,@orderId int, @customerId int,
			@originalorderid int, @orderstatusid int, @oriorderstatusid int, @deleteOrderStatusId int
	select @deleteOrderStatusId = OrderstatusId from Deleted
	select @TargetstatusId = OrderstatusId, @orderId = OrderId, @customerId = customerid from Inserted
--	if(@orderId is not null)
--	begin
--		INSERT INTO [dbo].[OrderStatusHistory]
--				([OrderId]
--				,[OrderStatusId]
--				,[StatusUpdatedBy]
--				,[UpdateDate]
--				,[InsertDate]
--				,[SaveDate])
--			VALUES
--				(@orderId,@TargetstatusId,null,getdate(),getdate(),getdate())
--	end

	select @originalorderid = case when ParentOrderId is not null then ParentOrderId 
								   when originalorderid is not null then originalorderid
								   else @orderId end from orderbook with (nolock) 
	where OrderId = @orderId 

	select @orderstatusid = orderstatusid from customerorder with (nolock) 
	where OrderId = @originalorderid 

	declare @OrderId_tmp int
	select top 1 @OrderId_tmp = OrderId from OrderBook with (nolock) where OrderStatusId <> 4 
	and (OriginalOrderId = @originalorderid or OrderId = @originalorderid)

	if(@customerId <> 2)
	begin
		if(@TargetstatusId in (2, 3, 4, 5, 7, 11, 12))
		begin
			if(@TargetstatusId in (3, 4) and @orderstatusid in (1,2, 3, 12))
			begin 
				if(@OrderId_tmp is not null)
				begin
					update CustomerOrder set OrderStatusId = 3,  UpdateDate = getdate()
					where OrderId = @originalorderid
				end
				else
				begin
					update CustomerOrder set OrderStatusId = 4,  UpdateDate = getdate()
					where OrderId = @originalorderid 
				end
			end
			else if(@TargetstatusId in (2) and @orderstatusid in (1,7))
			begin
				update CustomerOrder set OrderStatusId = @TargetstatusId,  UpdateDate = getdate()
				where OrderId = @originalorderid 
			end
			else if(@TargetstatusId in (7) and @orderstatusid in (1,2, 3))
			begin
				update CustomerOrder set OrderStatusId = @TargetstatusId,  UpdateDate = getdate()
				where OrderId = @originalorderid 
			end
			else if(@TargetstatusId in (5) and @orderstatusid in (2, 3, 4, 7, 12))
			begin
				update CustomerOrder set OrderStatusId = @TargetstatusId,  UpdateDate = getdate()
				where OrderId = @originalorderid 
			end
			else if(@TargetstatusId in (11) and @orderstatusid in (1,2, 3, 7))
			begin
				update CustomerOrder set OrderStatusId = @TargetstatusId,  UpdateDate = getdate()
				where OrderId = @originalorderid 
			end
			else if(@TargetstatusId in (12))
			begin
				update CustomerOrder set OrderStatusId = @TargetstatusId,  UpdateDate = getdate()
				where OrderId = @originalorderid 
			end
		end
		if(@TargetstatusId in (8, 9, 13, 14))
		begin
			update CustomerOrder set OrderStatusId = 2,  UpdateDate = getdate()
			where OrderId = @originalorderid 
		end

------------------------------------------------------------------分割线--------------------------------------------------------------
		if(@TargetstatusId = 2 and @deleteOrderStatusId in (13, 14))
		begin
			declare @triggerExecutes_Noti bit, @triggerExecutes_Email bit, @takeProfitExecutes_Noti bit, @takeProfitExecutes_Email bit,
				@stopLossExecutes_Noti bit, @stopLossExecutes_Email bit, @orderClassId int, @marketOrder bit, 
				@message nvarchar(500), @UID uniqueidentifier, @isRead bit, @sendEmail bit,
				@userName nvarchar(100), @orderType varchar(50), @quantity decimal(38, 8), @total decimal(38, 8), @average decimal(38, 8),
				@triggerPrice decimal(18, 8), @stopLossPrice decimal(18, 8), @notified bit, @type nvarchar(50), @assetTypeId int
			
			select 
				@triggerPrice = AD.TriggerPrice,
				@stopLossPrice = AD.StopLossPrice,
				@notified = AD.Notified,
				@assetTypeId = case when O.WantAssetTypeId = 1 then O.OfferAssetTypeId else O.WantAssetTypeId end
			from OrderBook O with (nolock) 
			left join AdvancedOrderProperties AD on O.OrderId = AD.OrderId
			where O.OrderId = @orderId

			select 
				@orderClassId = OrderClassId,
				@userName = C.UserName,
				@orderType = OT.Name,
				@quantity = Quantity,
				@total = Quantity * Price,
				@average = Price
			from OrderBook O with (nolock) 
			left join Customer C with (nolock) on O.CustomerId = C.CustomerId
			left join [OrderType_lkp] OT with (nolock) on O.OrderTypeId = OT.OrderTypeId
			where O.OrderId = @orderId or O.OriginalOrderId = @orderId
			
			--获取勾选内容, Noti默认值2， Email默认值3，Value=Noti*Email
			select @stopLossExecutes_Noti = case when Value % 2 = 0 then 1 else 0 end, 
				   @stopLossExecutes_Email = case when Value % 3 = 0 or @notified = 1 then 1 else 0 end 
			from CustomerPreference cp inner join Preference p on cp.PreferenceId = p.PreferenceId where p.Name = 'StopLossExecutes'
			select @triggerExecutes_Noti = case when Value % 2 = 0 then 1 else 0 end, 
				   @triggerExecutes_Email = case when Value % 3 = 0 or @notified = 1 then 1 else 0 end 
			from CustomerPreference cp inner join Preference p on cp.PreferenceId = p.PreferenceId where p.Name = 'TriggerExecutes'

			--StopLossExecutes
			if(@orderClassId = 3)
			begin
				set @isRead =  case when @stopLossExecutes_Noti = 1 then 0 else null end
				set @sendEmail = case when @stopLossExecutes_Email = 1 then 1 else 0 end
				set @type= '17094'  --StopLoss Triggered
				if(@orderType = 'Buy')
				begin
					set @message = '{"OrderType":"17101", "OrderId":"' + convert(varchar(50), @orderId) + 
								   '", "Quantity":"' + convert(varchar(50), @quantity) + 
								   '","Average": "' + convert(varchar(50), @average) + 
								   '", "Total":"' + convert(varchar(50), @total) +
								    '", "AssetTypeId":"' + convert(varchar(50), @assetTypeId) + '"}'
				end
				else if(@orderType = 'Sell')
				begin
					set @message = '{"OrderType":"17102", "OrderId":"' + convert(varchar(50), @orderId) + 
								   '", "Quantity":"' + convert(varchar(50), @quantity) + 
								   '","Average": "' + convert(varchar(50), @average) + 
								   '", "Total":"' + convert(varchar(50), @total) +
								    '", "AssetTypeId":"' + convert(varchar(50), @assetTypeId) + '"}'
				end
			end
			--TriggerExecutes
			else if(@orderClassId = 4)
			begin
				set @isRead =  case when @triggerExecutes_Noti = 1 then 0 else null end
				set @sendEmail = case when @triggerExecutes_Email = 1 then 1 else 0 end
				set @type= '17095'  --Trigger Triggered
				if(@orderType = 'Buy')
				begin
					set @message = '{"OrderType":"17103", "OrderId":"' + convert(varchar(50), @orderId) + 
								   '", "Quantity":"' + convert(varchar(50), @quantity) + 
								   '","Average": "' + convert(varchar(50), @average) + 
								   '", "Total":"' + convert(varchar(50), @total) +
								    '", "AssetTypeId":"' + convert(varchar(50), @assetTypeId) + '"}'
				end
				else if(@orderType = 'Sell')
				begin
					set @message = '{"OrderType":"17104", "OrderId":"' + convert(varchar(50), @orderId) + 
								   '", "Quantity":"' + convert(varchar(50), @quantity) + 
								   '","Average": "' + convert(varchar(50), @average) + 
								   '", "Total":"' + convert(varchar(50), @total) +
								    '", "AssetTypeId":"' + convert(varchar(50), @assetTypeId) + '"}'
				end
			end

			select @UID = NEWID()

			insert into [NotificationSetting](NotificationSettingUID, [Type], [Message], ReceiveUserId, CreateDate, CreateUserId, Isdelete)
			values(@UID, @type, @message, @customerId, getdate(), null, 0)

			insert into Notifications(NotificationSettingUID, ReceiveUserId, IsRead, ReadTime, SendEmail, SendEmailTime, IsDelete)
			values(@UID, @customerId, @isRead, null, @sendEmail, null, 0)
		end
	end
END
