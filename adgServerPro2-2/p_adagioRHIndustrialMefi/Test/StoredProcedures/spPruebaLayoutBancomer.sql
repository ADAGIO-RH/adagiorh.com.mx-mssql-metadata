USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Test].[spPruebaLayoutBancomer]
as
declare 
    @Consecutivo int = 1
    ,@NoCuenta varchar(50) = '1528454299'
    ,@Monto decimal(18,2) = 1.00
    ,@Nombre varchar(255) = 'RUBEN ALEJANDRO SOLIS AVILA'
    ,@Respuesta nvarchar(max)
 
    if object_id('tempdb..#tempResp') is not null
	   drop table #tempResp;

    create table #tempResp(Respuesta nvarchar(max));


    set @Respuesta =
	   [App].[fnAddString](9,@Consecutivo,'0',1)
	   +[App].[fnAddString](16,'',' ',1)
	   +'99'
	   +[App].[fnAddString](10,@NoCuenta,'0',1)
	   +[App].[fnAddString](10,'',' ',1)
	   +[App].[fnAddString](15,replace(cast(@Monto as varchar(15)),'.',''),'0',1)
	   +[App].[fnAddString](40,@Nombre,' ',2)
	   +[App].[fnAddString](6,'001001',' ',1)

    
    insert INTO #tempResp(Respuesta)
	   VALUES(@Respuesta)
		   --,(@Respuesta)
     

    select * from #tempResp
GO
