USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spActualizarTotalesRelacionesEmpleados] (
	@IDEmpleadoIni int = 0
	,@IDEmpleadoFin int = 999999999
) as 
declare 
	@IDUsuario int,
	@dtDetalleRelaciones [RH].[dtInfoOrganigrama]
	
	,@i int = 0
	;

	select @IDUsuario = cast(Valor as int)
	from  App.tblConfiguracionesGenerales
	where [IDConfiguracion] ='IDUsuarioAdmin'

	--if object_id('tempdb..#tblTempDetalleRelaciones') is not null drop table #tblTempDetalleRelaciones;

	--create table #tblTempDetalleRelaciones(
	--	IDJefeEmpleado int
	--	,IDEmpleado int
	--	,ClaveEmpleado varchar(20)
	--	,Empleado varchar(500)
	--	,IDJefe int
	--	,ClaveJefe varchar(20)
	--	,Jefe varchar(500)
	--	,IDTipoRelacion int
	--);


	if object_id('tempdb..#tblTempTotalRelacionesEmpleados') is not null drop table #tblTempTotalRelacionesEmpleados;
	create table #tblTempTotalRelacionesEmpleados (
		IDEmpleado int 
		,IDTipoRelacion int 
		,Total int
	);


	if object_id('tempdb..#tblTempEmpleados') is not null drop table #tblTempEmpleados;

	select IDEmpleado
	INTO #tblTempEmpleados
	from RH.tblEmpleadosMaster with (nolock)
	where IDEmpleado between @IDEmpleadoIni and @IDEmpleadoFin
	and Vigente = 1

	select @i = min(IDEmpleado) from #tblTempEmpleados

	while exists (select top 1 1 from #tblTempEmpleados where IDEmpleado >= @i)
	begin
		-- Jefes
		delete @dtDetalleRelaciones;

		insert  @dtDetalleRelaciones
		exec RH.spBuscarInfoOrganigramaEmpleado 
				 @IDEmpleado= @i
				,@IDTipoRelacion = 1
				,@IDUsuario =@IDUsuario

		insert into #tblTempTotalRelacionesEmpleados(IDEmpleado,IDTipoRelacion,Total)
		select @i,1, Total
		from ( select distinct count(IDJefe) as Total from @dtDetalleRelaciones ) totales

		--Subordinados
		delete @dtDetalleRelaciones;
		insert  @dtDetalleRelaciones
		exec RH.spBuscarInfoOrganigramaEmpleado 
				 @IDEmpleado= @i
				,@IDTipoRelacion = 2
				,@IDUsuario =@IDUsuario

		insert into #tblTempTotalRelacionesEmpleados(IDEmpleado,IDTipoRelacion,Total)
		select @i,2, Total
		from ( select distinct count(IDEmpleado) as Total from @dtDetalleRelaciones ) totales	

		-- Colegas	
		delete @dtDetalleRelaciones;
		insert  @dtDetalleRelaciones		
		exec RH.spBuscarInfoOrganigramaEmpleado 
				 @IDEmpleado= @i
				,@IDTipoRelacion = 3
				,@IDUsuario =@IDUsuario

		insert into #tblTempTotalRelacionesEmpleados(IDEmpleado,IDTipoRelacion,Total)
		select @i,3, Total
		from ( select distinct count(IDEmpleado) as Total from @dtDetalleRelaciones ) totales	


		select @i = min(IDEmpleado) from #tblTempEmpleados where IDEmpleado > @i;
	end;

	MERGE RH.tblTotalRelacionesEmpleados AS TARGET
	USING #tblTempTotalRelacionesEmpleados as SOURCE
	on TARGET.IDEmpleado = SOURCE.IDEmpleado and TARGET.IDTipoRelacion = SOURCE.IDTipoRelacion
	WHEN MATCHED THEN
		update 
			set TARGET.Total = SOURCE.Total
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT(IDEmpleado,IDTipoRelacion,Total)
		values(SOURCE.IDEmpleado, SOURCE.IDTipoRelacion, SOURCE.Total)
	;
GO
