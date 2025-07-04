USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Demo.spMoverColaboradoresDeTipoNomina(
@ClaveActual varchar(20) 
,@IDTipoNomina int = 61
,@IDClienteTo int = 10
) as
--- CLAVEEMPLEADO: CAF0002 IDEMPLEADO: 1304
declare 
	   @NuevaClave varchar(20)	-- = 'ADG0028'
	   ,@IDEmpleado int
	   ,@Fecha date
	   
	   ;

	select @IDEmpleado = IDEmpleado 
			,@Fecha = FechaAntiguedad 
	from RH.tblEmpleados where ClaveEmpleado = @ClaveActual

	declare @tempNuevaClave table (
		Clave varchar(20)
	)
	delete from @tempNuevaClave;

	INSERT @tempNuevaClave
	exec [RH].[spGenerarClaveEmpleado] @IDClienteTo,1

	select top 1 @NuevaClave = Clave from @tempNuevaClave

	delete from RH.tblTipoNominaEmpleado where IDEmpleado = @IDEmpleado
	delete from RH.tblClienteEmpleado where IDEmpleado = @IDEmpleado

	exec RH.spUITipoNominaEmpleado @IDTipoNominaEmpleado = 0
									,@IDEmpleado = @IDEmpleado
									,@IDTipoNomina = @IDTipoNomina
									,@FechaIni = @Fecha
									,@FechaFin = '2019-09-04' 

	update RH.tblEmpleados
		set ClaveEmpleado = @NuevaClave
	where ClaveEmpleado = @ClaveActual

	exec RH.spSincronizarEmpleadosMaster @NuevaClave,@NuevaClave

	--select * from RH.tblEmpleadosMaster where ClaveEmpleado = @ClaveActual	
	--select * from RH.tblEmpleadosMaster where ClaveEmpleado = @NuevaClave


	--select * from RH.tblEmpleadosMaster where IDTipoNomina = 4 order by ClaveEmpleado
	--select * from RH.tblEmpleadosMaster where IDTipoNomina = 24 order by ClaveEmpleado

	--select * from RH.tblEmpleados where ClaveEmpleado = 'ADG0012'
GO
