USE [AttendanceSystem]
GO
/****** Object:  Table [dbo].[Attendance]    Script Date: 2/10/2023 2:52:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Attendance](
	[Sr] [int] IDENTITY(1,1) NOT NULL,
	[EmpCode] [int] NULL,
	[SwipeDate] [datetime] NULL,
	[Swipe_In] [datetime] NULL,
	[Swipe_Out] [datetime] NULL,
	[Out_Time] [datetime] NULL,
	[In_Time] [datetime] NULL,
 CONSTRAINT [PK_Attendance] PRIMARY KEY CLUSTERED 
(
	[Sr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Attendance] ON 

INSERT [dbo].[Attendance] ([Sr], [EmpCode], [SwipeDate], [Swipe_In], [Swipe_Out], [Out_Time], [In_Time]) VALUES (1, 27183, CAST(N'2023-02-10T10:00:00.000' AS DateTime), CAST(N'2023-02-10T10:00:00.000' AS DateTime), CAST(N'2023-02-10T14:44:38.227' AS DateTime), CAST(N'2023-02-10T18:00:00.000' AS DateTime), CAST(N'1900-01-01T04:44:38.000' AS DateTime))
INSERT [dbo].[Attendance] ([Sr], [EmpCode], [SwipeDate], [Swipe_In], [Swipe_Out], [Out_Time], [In_Time]) VALUES (2, 27183, CAST(N'2023-02-10T14:44:56.783' AS DateTime), CAST(N'2023-02-10T14:44:56.783' AS DateTime), CAST(N'2023-02-10T14:48:29.317' AS DateTime), CAST(N'2023-02-10T18:00:00.000' AS DateTime), CAST(N'1900-01-01T00:03:33.000' AS DateTime))
INSERT [dbo].[Attendance] ([Sr], [EmpCode], [SwipeDate], [Swipe_In], [Swipe_Out], [Out_Time], [In_Time]) VALUES (3, 27183, CAST(N'2023-02-10T14:48:42.533' AS DateTime), CAST(N'2023-02-10T14:48:42.533' AS DateTime), CAST(N'2023-02-10T14:49:25.963' AS DateTime), CAST(N'2023-02-10T18:00:00.000' AS DateTime), CAST(N'1900-01-01T00:00:43.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[Attendance] OFF
GO
/****** Object:  StoredProcedure [dbo].[GetAllData]    Script Date: 2/10/2023 2:52:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Proc [dbo].[GetAllData]
as begin

 select * from [dbo].[Attendance] where EmpCode=27183 and convert(date,getdate())=convert(date,[SwipeDate])
end
GO
/****** Object:  StoredProcedure [dbo].[GetSwipIN_OutData]    Script Date: 2/10/2023 2:52:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Proc [dbo].[GetSwipIN_OutData]
as begin

 select top 1 * from [dbo].[Attendance] where EmpCode=27183 and convert(date,getdate())=convert(date,[SwipeDate])
 order by [Swipe_In] desc
 
end
GO
/****** Object:  StoredProcedure [dbo].[SP_Completed_Hrs]    Script Date: 2/10/2023 2:52:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[SP_Completed_Hrs] --exec [SP_Completed_Hrs] '12/1/23'
@CompletedHr varchar(100) out 
as begin

              declare @In_TimeCur datetime

                             declare @In_TimeAddition datetime = '2000-01-01 00:00:00.000'

                             DECLARE db_cursor CURSOR FOR

                                    --select isnull([In_Time],'2000-01-01 00:00:00.000')[In_Time] from [Attendance] where convert(date,[SwipeDate])=convert(date,GETDATE()) order by Sr
									select [In_Time] from [Attendance] where convert(date,[SwipeDate])=convert(date,GETDATE()) order by Sr

                             OPEN db_cursor 

                             FETCH NEXT FROM db_cursor INTO @In_TimeCur

                          WHILE @@FETCH_STATUS = 0 

                                    BEGIN                                 

                                           set @In_TimeAddition = @In_TimeAddition +   @In_TimeCur                                       

                                    FETCH NEXT FROM db_cursor INTO @In_TimeCur                                      

                                    END

                             CLOSE db_cursor 

                             DEALLOCATE db_cursor

 

                             set @CompletedHr= Convert(varchar(50), Convert(time, CONVERT(datetime, CAST(@In_TimeAddition AS TIME) )))
							 print @CompletedHr
 

end

 

 

 

GO
/****** Object:  StoredProcedure [dbo].[SP_SWIP_IN]    Script Date: 2/10/2023 2:52:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[SP_SWIP_IN]

as begin

declare @GETDATE datetime =  Getdate() --'2023-02-10 10:00:00.000' --  Getdate()

declare @swipouttimeofday datetime

                      set @swipouttimeofday =

                                    ( select top 1 [Swipe_Out] from [Attendance]

                                       where CONVERT(date, @GETDATE) = CONVERT(date, [SwipeDate])

                                      order by [Swipe_In] desc                                

                                     )

if(@swipouttimeofday is null)

       begin

       print 'NULL'

              insert into [Attendance] ([EmpCode],[SwipeDate],[Swipe_In],[Swipe_Out],[Out_Time],[In_Time]) values

              ('27183' , @GETDATE,@GETDATE,null,dateAdd(hh, 8 , @GETDATE),null)

       end

else

       begin

       print 'Not NULL'

              declare @Previous_swipouttimeofday datetime

                      set @Previous_swipouttimeofday =

                                    ( select top 1 [Swipe_Out] from [Attendance]

                                       where CONVERT(date, @GETDATE) = CONVERT(date, [SwipeDate])

                                       and [Swipe_Out] is not null

                                      order by [Swipe_In] desc                                

                                     )    

 

              declare @Swipe_diff INT

                      set @Swipe_diff = --(select convert(varchar(5),DateDiff(s, @Previous_swipouttimeofday,@GETDATE)/3600)+':'+convert(varchar(5),DateDiff(s, @Previous_swipouttimeofday,@GETDATE)%3600/60)+':'+convert(varchar(5),(DateDiff(s, @Previous_swipouttimeofday,@GETDATE)%60)) )

                      (select datediff(minute,@Previous_swipouttimeofday,@GETDATE))

 

                      print @Swipe_diff

 

              declare @Previous_Outtime datetime

                      set @Previous_Outtime =

                                    ( select top 1 [Out_Time] from [Attendance]

                                       where CONVERT(date, @GETDATE) = CONVERT(date, [SwipeDate])

                                       and [Swipe_Out] is not null

                                      order by [Swipe_In] desc                                

                                     )    

              PRINT @Previous_Outtime

                     

             

              insert into [Attendance] ([EmpCode],[SwipeDate],[Swipe_In],[Swipe_Out],[Out_Time],[In_Time]) values

                      ('27183',@GETDATE,@GETDATE,null,dateAdd(minute, @Swipe_diff,@Previous_Outtime),null)    

                     

       end

end

 

GO
/****** Object:  StoredProcedure [dbo].[SP_SWIP_OUT]    Script Date: 2/10/2023 2:52:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[SP_SWIP_OUT]

as begin

declare @GETDATE datetime = GETDATE() --'2023-02-10 11:35:00.000' --GETDATE() --

-- check if there's any swipe-in recorded for that day

declare @swipINtimeofday datetime

                      set @swipINtimeofday =

                                    ( select top 1 [Swipe_In] from [Attendance]

                                       where CONVERT(date, @GETDATE) = CONVERT(date, [SwipeDate])

                                      order by [Swipe_In] desc                                

                                     )

print @swipINtimeofday

declare @swipINSr int

                      set @swipINSr =

                                    ( select top 1 Sr from [Attendance]

                                       where CONVERT(date, @GETDATE) = CONVERT(date, [SwipeDate])

                                      order by [Swipe_In] desc                                

                                     )

print @swipINSr

if(@swipINtimeofday is not null) -- swipe-in recorded for that day

   begin

              declare @Swipe_diff INT

                      set @Swipe_diff = (select datediff(minute,@GETDATE , @swipINtimeofday))

 

              update [dbo].[Attendance] set [Swipe_Out]=@GETDATE , [In_Time]=

                      convert(varchar(5),DateDiff(s, @swipINtimeofday, @GETDATE)/3600)+':'+convert(varchar(5),DateDiff(s, @swipINtimeofday, @GETDATE)%3600/60)+':'+convert(varchar(5),(DateDiff(s, @swipINtimeofday, @GETDATE)%60))

                      where Sr=@swipINSr

       end   

else -- swipe-in Not recorded for that day

       begin

       --check, the previous day the swipe-out time

              declare @PreviousDay_Swip_OUT datetime =(select top 1 Swipe_Out from Attendance where convert(date,[SwipeDate])=convert(date,@GETDATE-1) order by Sr desc)

              --check the swipe-in of the previous day

              declare @PreviousDay_Swip_In datetime  =(select top 1 Swipe_In from Attendance where convert(date,[SwipeDate])=convert(date,@GETDATE-1) order by Sr desc)

 

              if(@PreviousDay_Swip_OUT is not null) --If the swipe-out time of the previous day is present

                      begin

                             if(@PreviousDay_Swip_In < @PreviousDay_Swip_OUT) -- A

                                    begin

                                    -- error msg a

                                           print 'Please contact administrator, your swipe-in information is not available!'

                                    end

                             if(@PreviousDay_Swip_In > @PreviousDay_Swip_OUT) --B

                                    begin

                                           print 'OK'

                                    end

                      end

              else

                      begin

                             declare @In_TimeCur datetime

                             declare @In_TimeAddition datetime ='2000-01-01 00:00:00.000'

                             DECLARE db_cursor CURSOR FOR

                                    select [In_Time] from [Attendance] where convert(date,[SwipeDate])=convert(date,GETDATE()-1) order by Sr

                             OPEN db_cursor 

                             FETCH NEXT FROM db_cursor INTO @In_TimeCur

                          WHILE @@FETCH_STATUS = 0 

                                    BEGIN 

                                           set @In_TimeAddition = @In_TimeAddition +   @In_TimeCur

                                           FETCH NEXT FROM db_cursor INTO @In_TimeCur

                                    END

                             CLOSE db_cursor 

                             DEALLOCATE db_cursor

 

                             declare @New_Time datetime= DATEADD(MINUTE, (LTRIM(DATEDIFF(MINUTE, 0, convert(time,@In_TimeAddition))))*-1  , @PreviousDay_Swip_In)

                             declare @PrevDaySwipIN_Sr int = (select top 1 Sr from [Attendance]

                                       where CONVERT(date, @GETDATE-1) = CONVERT(date, [SwipeDate])

                                      order by [Swipe_In] desc         )

                                      DECLARE @date DATETIME, @time DATETIME

                                           SET @date=convert(date,getdate()-1)

                                           SET @time='23:59:59'

                                           SET @date=@date+@time                                   

                                                                                

                             update [Attendance] set Swipe_Out = @date , In_Time=@date-@PreviousDay_Swip_In where sr=@PrevDaySwipIN_Sr

                            

                                     SET @date=convert(date,getdate())

                                           SET @time='00:00:00'

                                           SET @date=@date+@time      

 

                             --declare @intime datetime =convert(varchar(10),DateDiff(s, @date, @PreviousDay_Swip_In)/3600)+':'+convert(varchar(5),DateDiff(s, @date, @PreviousDay_Swip_In)%3600/60)+':'+convert(varchar(5),(DateDiff(s,@date, @PreviousDay_Swip_In)%60))
							   declare @intime datetime =convert(varchar(10),DateDiff(s, @date,@GETDATE)/3600)+':'+convert(varchar(5),DateDiff(s, @date,@GETDATE)%3600/60)+':'+ convert(varchar(5),(DateDiff(s,@date,@GETDATE)%60))

                              

                             insert into [Attendance] ([EmpCode],[SwipeDate],[Swipe_In],[Swipe_Out],[Out_Time],[In_Time]) values

                             ( '27183' , @GETDATE,@date,@GETDATE ,dateAdd(hh, 8 , @date),

                            @intime

                             )

                      end                  

       end

end

      
 
 
GO
/****** Object:  StoredProcedure [dbo].[SWIP_IN_Curser]    Script Date: 2/10/2023 2:52:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE proc [dbo].[SWIP_IN_Curser]
as begin
declare @Empcode int=27183
declare @sr int, @EmpCodeCur int ,@Swipe_IN datetime ,@Swipe_Out datetime ,@Out_Time  varchar(100),@In_Time varchar(100)


declare @SwipeCount int 
set @SwipeCount=(select count(*) from [Attendance] where CONVERT(date, GETDATE())=CONVERT(date,[SwipeDate]))
print @SwipeCount

if(@SwipeCount = 0)
	begin
		insert into [Attendance] ([EmpCode],[SwipeDate],[Swipe_In],[Swipe_Out],[Out_Time],[In_Time]) values
		('27183' , GETDATE(),GETDATE(),null,dateAdd(hh, 8 , GETDATE()),null)
	end
else
	begin
		DECLARE db_cursor CURSOR FOR 

		SELECT top 1 Sr
			  ,[EmpCode]
			  ,[Swipe_In]
			  ,[Swipe_Out]
			  ,[Out_Time]
			  ,[In_Time]
		  FROM [AttendanceSystem].[dbo].[Attendance]
		  where CONVERT(date, GETDATE()) = CONVERT(date, Swipe_In)
		  order by [Swipe_In] desc

		OPEN db_cursor  
		FETCH NEXT FROM db_cursor INTO @Sr, @EmpCodeCur,@Swipe_IN,@Swipe_Out,@Out_Time  ,@In_Time

		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			  if(@Swipe_Out is null)
			  begin	  	  
					update [dbo].[Attendance] set [Out_Time]= dateAdd(hh, 8 , Swipe_In )
					where [Sr] = @Sr  

					 
			  end
			  else
			  begin
				print @Swipe_IN 
					Update [dbo].[Attendance] set
					[Out_Time]= convert(varchar(5),DateDiff(s, @Swipe_IN, getdate())/3600)+':'+convert(varchar(5),DateDiff(s, @Swipe_IN, getdate())%3600/60)+':'+convert(varchar(5),(DateDiff(s, @Swipe_IN, getdate())%60)) 
					where [EmpCode]=@Empcode and [Sr] = @Sr
			  end
			  FETCH NEXT FROM db_cursor INTO @Sr, @EmpCodeCur,@Swipe_IN,@Swipe_Out,@Out_Time  ,@In_Time
		END 

		CLOSE db_cursor  
		DEALLOCATE db_cursor

	end

end

GO
