USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarTipoNominaEmpleado]
(
	@IDTipoNominaEmpleado int,
	@IDUsuario int
)
AS
BEGIN
	Declare 
		@IDEmpleado int = 0
		,@IDCliente int = 0
		,@NuevoIDCliente int = 0
		,@Fecha date
		,@IDClienteEmpleado int = 0
	;

	select @IDEmpleado=tne.IDEmpleado
		 ,@IDCliente = tn.IDCliente
		,@Fecha = tne.FechaIni
	from RH.tblTipoNominaEmpleado tne with (nolock)
		join Nomina.tblCatTipoNomina tn on tne.IDTipoNomina = tn.IDTipoNomina
	where tne.IDTipoNominaEmpleado = @IDTipoNominaEmpleado

		 
		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblTipoNominaEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoNominaEmpleado = @IDTipoNominaEmpleado
    	

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblTipoNominaEmpleado]','[RH].[spBorrarTipoNominaEmpleado]','DELETE','',@OldJSON



	Delete RH.tblTipoNominaEmpleado 
	where IDTipoNominaEmpleado = @IDTipoNominaEmpleado

	select top 1 @NuevoIDCliente = tn.IDCliente
		
	from RH.tblTipoNominaEmpleado tne with (nolock)
		join Nomina.tblCatTipoNomina tn on tne.IDTipoNomina = tn.IDTipoNomina
	where tne.IDEmpleado = @IDEmpleado
	order by FechaFin desc

	if (@IDCliente <> @NuevoIDCliente)
	begin
		select top 1 @IDClienteEmpleado = IDClienteEmpleado
		from RH.tblClienteEmpleado
		where IDCliente = @IDCliente and FechaIni = @Fecha
		
		exec [RH].[spBorrarClienteEmpleado] @IDClienteEmpleado=@IDClienteEmpleado, @IDUsuario = @IDUsuario
		--delete from RH.tblClienteEmpleado
		--where IDCliente <> @NuevoIDCliente and FechaIni > @Fecha
	end;
	
    if OBJECT_ID('tempdb..#tblTempHistorial1') is not null
	   drop table #tblTempHistorial1;

    if OBJECT_ID('tempdb..#tblTempHistorial2') is not null
	   drop table #tblTempHistorial2;

    select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
    INTO #tblTempHistorial1
    FROM RH.tblTipoNominaEmpleado with (nolock)
    WHERE IDEmpleado = @IDEmpleado
    order by FechaIni asc

    select 
	   t1.IDTipoNominaEmpleado
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
    FROM RH.tblTipoNominaEmpleado as [TARGET]
	   join #tblTempHistorial2 as [SOURCE] on [TARGET].IDTipoNominaEmpleado = [SOURCE].IDTipoNominaEmpleado	

	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
END
GO
