USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [RH].[spEjecutarAsignacionesPredeterminadas](
	@EmpleadoIni Varchar(20) = '0'               
	,@EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ'                
	,@IDUsuario int 
) as
--declare 
--	 @EmpleadoIni Varchar(20) = '0'               
--	,@EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ'                
--	,@IDUsuario int = 1

--	;
declare 
	@dtEmpleados RH.dtEmpleados
	,@IDEmpleado int = 0
	,@Jefes nvarchar(max)
	,@Supervisores nvarchar(max)
	,@Lectores nvarchar(max)
	;

	if object_id('tempdb..#tempEmps') is not null drop table #tempEmps;

	insert @dtEmpleados
	select *
	from RH.tblEmpleadosMaster
	where ClaveEmpleado between  @EmpleadoIni and @EmpleadoFin

	select e.IDEmpleado, c.*
	INTO #tempEmps
	from [RH].[tblConfigAsignacionesPredeterminadas] c
		left join @dtEmpleados e on 
			(e.IDDepartamento = c.IDDepartamento or c.IDDepartamento is null)
			and (e.IDSucursal = c.IDSucursal or c.IDSucursal is null)
			and (e.IDPuesto = c.IDPuesto or c.IDPuesto is null)
			and (e.IDClasificacionCorporativa = c.IDClasificacionCorporativa or c.IDClasificacionCorporativa is null)
			and (e.IDDivision = c.IDDivision or c.IDDivision is null)		
			and (e.IDTipoNomina = c.IDTipoNomina or c.IDTipoNomina is null)
            and (e.IDRazonSocial = c.IDRazonSocial or c.IDRazonSocial is null)
			and (e.IDRegion = c.IDRegiones or c.IDRegiones is null)
			and (e.IDRegPatronal = c.IDRegPatronal or c.IDRegPatronal is null)
			and (e.IDArea = c.IDAreas or c.IDAreas is null)
			and (e.IDCentroCosto = c.IDCentroCostos or c.IDCentroCostos is null)
			and (e.IDCliente = c.IDCliente or c.IDCliente is null)
			and (e.IDTipoPrestacion = c.IDTipoPrestaciones or c.IDTipoPrestaciones is null)
	where e.IDEmpleado is not null
	order by e.IDEmpleado
	
	;WITH tempEmpsCTE (IDEmpleado,duplicateRecCount)
	AS
	(
	SELECT IDEmpleado,ROW_NUMBER() OVER(PARTITION by IDEmpleado ORDER BY Factor desc) AS duplicateRecCount
	FROM #tempEmps
	)
	--Now Delete Duplicate Rows
	DELETE FROM tempEmpsCTE
	WHERE duplicateRecCount > 1 

	--select * from #tempEmps order by IDEmpleado

	select @IDEmpleado = min(IDEmpleado) from #tempEmps;

	while exists(select top 1 1 from #tempEmps where IDEmpleado >= @IDEmpleado)
	begin
		print @IDEmpleado


		select @Jefes 	   = IDsJefe
			,@Supervisores = IDsSupervisores
			,@Lectores     = IDsLectores
		from #tempEmps
		where IDEmpleado = @IDEmpleado

		if (@Jefes is not null)
		begin
			insert into RH.tblJefesEmpleados(IDEmpleado,IDJefe)
			select @IDEmpleado, cast(item as int)
			from app.Split(@Jefes,',') 
			where cast(item as int) not in (select IDJefe from RH.tblJefesEmpleados where IDEmpleado = @IDEmpleado)
		end;

		if (@Supervisores is not null)
		begin
			insert into Seguridad.tblDetalleFiltrosEmpleadosUsuarios(IDUsuario,IDEmpleado,Filtro,ValorFiltro)
			select u.IDUsuario, @IDEmpleado, 'Empleados','Empleados | '+e.NOMBRECOMPLETO
			from app.Split(@Supervisores,',') s
				join Seguridad.tblUsuarios u on cast(s.item as int) = u.IDEmpleado
				join rh.tblEmpleadosMaster e on u.IDEmpleado = e.IDEmpleado
 			where @IDEmpleado not in (select IDEmpleado from Seguridad.tblDetalleFiltrosEmpleadosUsuarios where IDUsuario = u.IDUsuario)
		end;

		if (@Lectores is not null)
		begin
			insert into Asistencia.tblLectoresEmpleados(IDLector,IDEmpleado)
			select cast(l.item as int), @IDEmpleado
			from app.Split(@Lectores,',') l
				inner join Asistencia.tblLectores ll with(nolock)
					on ll.IDLector = cast(l.item as int)
			where cast(l.item as int) not in (select IDLector from  Asistencia.tblLectoresEmpleados where IDEmpleado = @IDEmpleado)
		end;

		select @IDEmpleado = min(IDEmpleado) from #tempEmps where IDEmpleado > @IDEmpleado;
	end;

	--select * from #tempEmps  order by IDEmpleado

	--sp_helptext 'RH.spBuscarEmpleadosMaster'
GO
