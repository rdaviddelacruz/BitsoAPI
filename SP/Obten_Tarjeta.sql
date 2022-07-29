USE [Criptos]
GO
/****** Object:  StoredProcedure [dbo].[Obten_Tarjeta]    Script Date: 21/06/2022 09:48:37 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Obten_Tarjeta]
as
declare @obj int
    declare @url varchar(500)
    declare @RESULTADO  nvarchar(4000) 
    DECLARE @hResult1 int
	DECLARE @hResult int
    DECLARE @source varchar(255), @desc varchar(255)
	 DECLARE @respuesta  as VARCHAR(8000)
    DECLARE @body  as varchar(8000) = 
	''


  set @url =  	'https://api.bitso.com/v3/ticker/?book=xrp_mxn'
 
    exec sp_OACreate 'MSXML2.XMLHTTP.6.0',@obj out
	
	  EXEC sp_OAMethod @Obj,'open',NULL, 'GET', @URL, false,NULL,NULL

  --  EXEC sp_OAMethod @Obj,'open',NULL, 'POST', @URL, false,@Username,@Password
    
    EXEC sp_OAMethod @Obj, 'setRequestHeader', NULL, 'Content-Type', 'application/json'
	
    --exec sp_OAMethod @obj, 'setRequestHeader', NULL, 'Username',@UserName
    --exec sp_OAMethod @obj, 'setRequestHeader', NULL, 'Password',@Password
	-- exec sp_OAMethod @obj, 'setRequestHeader', NULL, 'SOAPAction',''
	
  --  EXEC @hResult1 = sp_OAMethod @obj,'setOption',NULL,3,'LOCAL_MACHINE\My\localhost';
  
  

   --  EXEC   sp_OAMethod @Obj, 'send', null, @body 
       EXEC @hResult = sp_OAMethod @Obj, send, NULL, ''
	    IF @hResult <> 0 
    BEGIN
          EXEC sp_OAGetErrorInfo @obj, @source OUT, @desc OUT
          SELECT      hResult = convert(varbinary(4), @hResult), 
                      source = @source, 
                      description = @desc, 
                      FailPoint = 'Create failed2', 
                      MedthodName = 'GET' 
          goto destroy 
          return
    END
    
    exec @hResult =sp_OAGetProperty @obj,'ResponseText', @RESULTADO OUT
  
select * from OPENJSON(@RESULTADO, '$.payload')
with([high] [numeric] (16,8) '$.high',
	 [last] [numeric] (16,8) '$.last',
	 [created_at] [varchar] (30) '$.created_at',
	 book [varchar] (8) '$.book',
	 volume [numeric] (16,8) '$.volume',
	 vwap [numeric] (16,8) '$.vwap',
	 [low] [numeric] (16,8) '$.low',
	 [ask] [numeric] (16,8) '$.ask',
	 [bid][numeric] (16,8) '$.bid',
	 [change_24] [numeric] (16,8) '$.change_24',
	 [rolling_average_change] [numeric] (16,8) '$.rolling_average_change."6"'
) 
   destroy: 
   exec sp_OADestroy @Obj 
   
   