USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarClienteEmpleado]
(
	@IDClienteEmpleado int,
	@IDUsuario int
)
AS
BEGIN
	   declare @IDEmpleado int = 0;

	   	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblClienteEmpleado] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDClienteEmpleado = @IDClienteEmpleado

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblClienteEmpleado]','[RH].[spBorrarClienteEmpleado]','DELETE','',@OldJSON


	   select @IDEmpleado=IDEmpleado
	   from RH.tblClienteEmpleado 
	   where IDClienteEmpleado = @IDClienteEmpleado

	    Delete RH.tblClienteEmpleado 
	    where IDClienteEmpleado = @IDClienteEmpleado

	   if OBJECT_ID('tempdb..#tblTempHistorial1') is not null
	   drop table #tblTempHistorial1;

	   if OBJECT_ID('tempdb..#tblTempHistorial2') is not null
		  drop table #tblTempHistorial2;

	   select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
	   INTO #tblTempHistorial1
	   FROM RH.tblClienteEmpleado
	   WHERE IDEmpleado = @IDEmpleado
	   order by FechaIni asc

	   select 
	    t1.IDClienteEmpleado
	   ,t1.IDEmpleado
	   ,t1.IDCliente
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
	   FROM RH.tblClienteEmpleado as [TARGET]
		  join #tblTempHistorial2 as [SOURCE] on [TARGET].IDClienteEmpleado = [SOURCE].IDClienteEmpleado
		
	 EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
END
GO
