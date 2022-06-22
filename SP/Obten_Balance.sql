USE [Criptos]
GO
/****** Object:  StoredProcedure [dbo].[Obten_Balance]    Script Date: 17/06/2022 09:58:37 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[Obten_Balance]
as
declare @obj int
    declare @url varchar(500)
    declare @response as table(Json_Table nvarchar(max))
    declare @RESULTADO  nvarchar(max) 
    DECLARE @hResult1 int
	DECLARE @hResult int
    DECLARE @source varchar(255), @desc varchar(255)
	 DECLARE @respuesta  as VARCHAR(8000)
    DECLARE @body  as varchar(8000) = 
	''
    DECLARE @UserName nvarchar(100)
    DECLARE @Password nvarchar(100)
	DECLARE @b64 varbinary(max)
    DECLARE @key varbinary(max) = CAST((select top 1 llave from Opciones where Elemento = 'key1' ) AS varbinary(max))
    DECLARE @user varchar(20) = (select top 1 llave from Opciones where Elemento = 'User1')

	Declare @Numerador as int =( SELECT datediff(ss,'1970-01-01', getdate()))

	DECLARE @message varbinary(max) = CAST( convert(varchar,@Numerador)+ 'GET/v3/balance/' AS varbinary(max))
	SELECT @b64 = [dbo].HMAC('SHA2_256', @key, @message)
SELECT cast(N'' as xml).value('xs:base64Binary(sql:variable("@b64"))', 'varchar(128)');
Declare @codigo as varchar(3000)
SELECT @codigo = lower(CONVERT(nVARCHAR(1000), @b64, 2))

	Declare @autorizacion varchar(3000) = 'Bitso '+@user+':' +convert(varchar,@Numerador)+':'+@codigo+''



 
  set @url =  	'https://api.bitso.com/v3/balance/'
 --https://docs.oracle.com/en/cloud/saas/financials/20a/farfa/op-receivablesinvoices-get.html
    exec sp_OACreate 'MSXML2.XMLHTTP.6.0',@obj out
	
	  EXEC sp_OAMethod @Obj,'open',NULL, 'GET', @URL, false,NULL,NULL

  --  EXEC sp_OAMethod @Obj,'open',NULL, 'POST', @URL, false,@Username,@Password
    
    EXEC sp_OAMethod @Obj, 'setRequestHeader', NULL, 'Content-Type', 'application/json'
	
    --exec sp_OAMethod @obj, 'setRequestHeader', NULL, 'Username',@UserName
    --exec sp_OAMethod @obj, 'setRequestHeader', NULL, 'Password',@Password
	 exec sp_OAMethod @obj, 'setRequestHeader', NULL, 'Authorization',@autorizacion
	
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
    
    --exec sp_OAGetProperty @obj,'ResponseText', @response OUTPUT
      INSERT into @Response (Json_Table) exec sp_OAGetProperty @obj, 'ResponseText'  

SET @RESULTADO = (select TOP 1 Json_Table from @Response)
SELECT @RESULTADO
select * from OPENJSON(@RESULTADO, '$.payload.balances')
with(currency [varchar] (250) '$.currency',
	available [numeric] (16,8) '$.available',
	locked [numeric] (16,8) '$.locked',
	total [numeric] (16,8) '$.total',
	pending_deposit [numeric] (16,8) '$.pending_deposit',
	pending_withdrawal [numeric] (16,8) '$.pending_withdrawal'          
) where currency in ('mxn','xrp')
   destroy: 
   exec sp_OADestroy @Obj 
   
