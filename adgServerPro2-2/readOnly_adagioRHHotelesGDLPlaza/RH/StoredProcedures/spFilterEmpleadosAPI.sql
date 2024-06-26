USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca empleados por Nombre y/o clave Empleado
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-12-24
** Paremetros		:              
	@tipo = -1		: Ambos
			0		: No Vigentes
			1		: Vigentes
			

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE proc [RH].[spFilterEmpleadosAPI](  
	@tipo int = -1,
	@claveEmpleado varchar(20) = null,
	@fechaUltimaActualizacion date = null,
	@fechaIngreso date = null,
	@IDUsuario int
)as   

	declare 
		@vigencia bit = null,
		@FechaIni date = getdate(),
		@Fechafin date = getdate()
	;

	if object_id('tempdb..#tempMovAfil') is not null drop table #tempMovAfil    
  
	select 
		mm.IDEmpleado
		--,FechaAlta
		,FechaBaja
		--,case when ((mm.FechaBaja is not null and mm.FechaReingreso is not null) and mm.FechaReingreso > mm.FechaBaja) then mm.FechaReingreso else null end as FechaReingreso
		--,mm.FechaReingresoAntiguedad
		--,mm.IDMovAfiliatorio    
		--,mm.SalarioDiario
		--,mm.SalarioVariable
		--,mm.SalarioIntegrado
		--,mm.SalarioDiarioReal
	into #tempMovAfil  
	from IMSS.TblVigenciaEmpleado mm with (nolock)
	where ( mm.FechaAlta<=@FechaFin and (mm.FechaBaja>=@FechaIni or mm.FechaBaja is null)) or (mm.FechaReingreso<=@FechaFin)

	set @vigencia = case when @tipo = -1 then null else CAST(@tipo as bit) end

	select
		 e.IDEmpleado
		,e.ClaveEmpleado
		,e.IMSS
		,e.Nombre
		,e.SegundoNombre
		,e.Paterno
		,e.Materno
		,e.NOMBRECOMPLETO
		,e.Sexo
		,isnull(e.FechaIngreso,'1990-01-01') as FechaIngreso
		,isnull(e.FechaAntiguedad,'1990-01-01') as FechaAntiguedad
		--,ISNULL(mov.FechaBaja, '1990-01-01') as FechaUltimaBaja
		,mov.FechaBaja as FechaUltimaBaja
		,isnull(e.IDDepartamento,0) as IDDepartamento
		,d.Codigo as CodigoDepartamento
		,e.Departamento
		,isnull(e.IDSucursal,0) as IDSucursal
		,s.Codigo as CodigoSucursal
		,e.Sucursal
		,isnull(e.IDPuesto,0) as IDPuesto
		,p.Codigo as CodigoPuesto
		,e.Puesto
		,isnull(uae.Fecha,getdate()) as FechaUltimaActualizacion
		,e.Vigente
	from [RH].[tblEmpleadosMaster] e with (nolock)
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		left join RH.tblCatSucursales s with (nolock) on s.IDSucursal = e.IDSucursal
		left join RH.tblCatDepartamentos d with (nolock) on d.IDDepartamento = e.IDDepartamento
		left join RH.tblCatPuestos p with (nolock) on p.IDPuesto = e.IDPuesto
		left join RH.tblUltimaActualizacionEmpleados uae with (nolock) on uae.IDEmpleado = e.IDEmpleado
		left join #tempMovAfil mov on mov.IDEmpleado = e.IDEmpleado
	where (e.Vigente = case when @vigencia is not null then @vigencia else e.Vigente end)
		and (e.ClaveEmpleado = @claveEmpleado or @claveEmpleado is null)
		and (CAST(isnull(uae.Fecha,getdate()) as date) = @fechaUltimaActualizacion or @fechaUltimaActualizacion is null)
		and (isnull(e.FechaIngreso,'1990-01-01') = @fechaIngreso or @fechaIngreso is null)
	order by ClaveEmpleado asc
GO
