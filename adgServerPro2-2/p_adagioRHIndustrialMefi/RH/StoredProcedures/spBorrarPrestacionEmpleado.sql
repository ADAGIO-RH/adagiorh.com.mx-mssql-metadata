USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarPrestacionEmpleado]
(
	@IDPrestacionEmpleado int,
	@IDUsuario int 
	
)
AS
BEGIN
    declare @IDEmpleado int = 0;

	
	  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblPrestacionesEmpleado] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDPrestacionEmpleado = @IDPrestacionEmpleado
    	

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblPrestacionesEmpleado]','[RH].[spBorrarPrestacionEmpleado]','DELETE','',@OldJSON



    select @IDEmpleado=IDEmpleado
    from RH.tblPrestacionesEmpleado 
    where IDPrestacionEmpleado = @IDPrestacionEmpleado

    DELETE RH.tblPrestacionesEmpleado 
    where IDPrestacionEmpleado = @IDPrestacionEmpleado

    if OBJECT_ID('tempdb..#tblTempHistorial1') is not null
	   drop table #tblTempHistorial1;

    if OBJECT_ID('tempdb..#tblTempHistorial2') is not null
	   drop table #tblTempHistorial2;

    select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
    INTO #tblTempHistorial1
    FROM RH.tblPrestacionesEmpleado with (nolock)
    WHERE IDEmpleado = @IDEmpleado
    order by FechaIni asc

    select 
	   t1.IDPrestacionEmpleado
	   ,t1.IDEmpleado	  
	   ,t1.FechaIni
	   ,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni) 
				else '9999-12-31' end 
    INTO #tblTempHistorial2
    from #tblTempHistorial1 t1
	   left join (select * 
				from #tblTempHistorial1) t2 on t1.[Row] = (t2.[Row]-1)

    update [TARGET]
    set 
	   [TARGET].FechaFin = [SOURCE].FechaFin
    FROM RH.tblPrestacionesEmpleado as [TARGET]
	   join #tblTempHistorial2 as [SOURCE] on [TARGET].IDPrestacionEmpleado = [SOURCE].IDPrestacionEmpleado		

	   EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
END
GO
