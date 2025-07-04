USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spReportePadres] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
	;   

	select 
		top 1 @IDIdioma = dp.Valor        
	from Seguridad.tblUsuarios u with (nolock)       
		Inner join App.tblPreferencias p with (nolock)        
			on u.IDPreferencia = p.IDPreferencia        
		Inner join App.tblDetallePreferencias dp with (nolock)        
			on dp.IDPreferencia = p.IDPreferencia        
		Inner join App.tblCatTiposPreferencias tp with (nolock)        
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia        
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'        
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	Declare 
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@FechaIni date 
			,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)
			,@FiltroEmpleado  Varchar(max)
			,@FiltroDepartamento  Varchar(max)
			,@FiltroSucursal  Varchar(max)
			,@FiltroPuesto  Varchar(max)
			,@FiltroPrestaciones  Varchar(max)
			,@FiltroClientes  Varchar(max)
			,@FiltroTiposContratacion  Varchar(max)
			,@FiltroRazonesSociales  Varchar(max)
			,@FiltroDivisiones  Varchar(max)
			,@FiltroNombreClave  Varchar(max)
	
		select @TipoNomina = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'TipoNomina'

		select @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'

		select @ClaveEmpleadoFinal = CASE WHEN ISNULL(Value,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'

		select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaIni'

		select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaFin'


		SET @FiltroEmpleado = (Select top 1 CAST(ITEM as  Varchar(max)) from App.Split(isnull((select value from @dtFiltros where catalogo = 'Empleados'),'0'),','))
		SET @FiltroDepartamento = (Select top 1 CAST(ITEM as  Varchar(max)) from App.Split(isnull((select value from @dtFiltros where catalogo = 'Departamentos'),'0'),','))
		SET @FiltroSucursal = (Select top 1 CAST(ITEM as  Varchar(max)) from App.Split(isnull((select value from @dtFiltros where catalogo = 'Sucursales'),'0'),','))
		SET @FiltroPuesto = (Select top 1 CAST(ITEM as  Varchar(max)) from App.Split(isnull((select value from @dtFiltros where catalogo = 'Puestos'),'0'),','))
		SET @FiltroPrestaciones = (Select top 1 CAST(ITEM as  Varchar(max)) from App.Split(isnull((select value from @dtFiltros where catalogo = 'Prestaciones'),'0'),','))
		SET @FiltroClientes = (Select top 1 CAST(ITEM as  Varchar(max)) from App.Split(isnull((select value from @dtFiltros where catalogo = 'Clientes'),'0'),','))
		SET @FiltroTiposContratacion = (Select top 1 CAST(ITEM as  Varchar(max)) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TiposContratacion'),'0'),','))
		SET @FiltroRazonesSociales = (Select top 1 CAST(ITEM as  Varchar(max)) from App.Split(isnull((select value from @dtFiltros where catalogo = 'RazonesSociales'),'0'),','))
		SET @FiltroDivisiones = (Select top 1 CAST(ITEM as  Varchar(max)) from App.Split(isnull((select value from @dtFiltros where catalogo = 'Divisiones'),'0'),','))
		select @FiltroNombreClave = CASE WHEN ISNULL(Value,'') = '' THEN '' ELSE  Value END from @dtFiltros where Catalogo = 'NombreClaveFilter'

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))


	if(@IDTipoVigente = 1)
	BEGIN
		select 
		 M.ClaveEmpleado as [Clave]
		,M.NOMBRECOMPLETO as [Nombre Empleado]
		,CASE
			WHEN M.Sexo = 'MASCULINO' THEN 'PADRE'
			WHEN M.Sexo = 'FEMENINO' THEN 'MADRE'
			ELSE 'NO ESPECIFICADO'
		END as [Paternidad Empleado]
		,M.Departamento as [Departamento]
		,M.Puesto as [Puesto]
		,M.Sucursal as [Sucursal]
		,count(fbe.IDEmpleado) as [Num Hijos]
		from [RH].[TblFamiliaresBenificiariosEmpleados] fbe
		join [RH].[TblCatParentescos] cp on fbe.IDParentesco = cp.IDParentesco
		join RH.tblEmpleadosMaster M on m.IDEmpleado = fbe.IDEmpleado
		left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario =@IDUsuario
		Where 
		M.Vigente=1 
		and fbe.IDParentesco in (4,5) 
		and (( M.IDEmpleado = @FiltroEmpleado or @FiltroEmpleado = 0)
		and ( M.Departamento = @FiltroDepartamento or @FiltroDepartamento = 0)
		and ( M.IDPuesto = @FiltroPuesto or @FiltroPuesto = 0)
		and ( M.IDTipoPrestacion = @FiltroPrestaciones or @FiltroPrestaciones = 0)
		and ( M.IDCliente = @FiltroClientes or @FiltroClientes = 0)
		and ( M.IDTipoContrato = @FiltroTiposContratacion or @FiltroTiposContratacion = 0)
		and ( M.IDRazonSocial = @FiltroRazonesSociales or @FiltroRazonesSociales = 0)
		and ( M.IDTipoNomina = @FiltroDivisiones or @FiltroDivisiones = 0))
		group by
		M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,M.Sexo
		,M.Departamento
		,M.Puesto
		,M.Sucursal


	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN

	select 
		 M.ClaveEmpleado as [Clave]
		,M.NOMBRECOMPLETO as [Nombre Empleado]
		,CASE
			WHEN M.Sexo = 'MASCULINO' THEN 'PADRE'
			WHEN M.Sexo = 'FEMENINO' THEN 'MADRE'
			ELSE 'NO ESPECIFICADO'
		END as [Paternidad Empleado]
		,M.Departamento as [Departamento]
		,M.Puesto as [Puesto]
		,M.Sucursal as [Sucursal]
		,count(fbe.IDEmpleado) as [Num Hijos]
		from [RH].[TblFamiliaresBenificiariosEmpleados] fbe
		join [RH].[TblCatParentescos] cp on fbe.IDParentesco = cp.IDParentesco
		join RH.tblEmpleadosMaster M on m.IDEmpleado = fbe.IDEmpleado
		left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario =@IDUsuario
		Where 
		M.Vigente=2
		and fbe.IDParentesco in (4,5) 
		and (( M.IDEmpleado = @FiltroEmpleado or @FiltroEmpleado = 0)
		and ( M.Departamento = @FiltroDepartamento or @FiltroDepartamento = 0)
		and ( M.IDPuesto = @FiltroPuesto or @FiltroPuesto = 0)
		and ( M.IDTipoPrestacion = @FiltroPrestaciones or @FiltroPrestaciones = 0)
		and ( M.IDCliente = @FiltroClientes or @FiltroClientes = 0)
		and ( M.IDTipoContrato = @FiltroTiposContratacion or @FiltroTiposContratacion = 0)
		and ( M.IDRazonSocial = @FiltroRazonesSociales or @FiltroRazonesSociales = 0)
		and ( M.IDTipoNomina = @FiltroDivisiones or @FiltroDivisiones = 0))
		group by
		M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,M.Sexo
		,M.Departamento
		,M.Puesto
		,M.Sucursal

	END 
	ELSE IF(@IDTipoVigente = 3)
	BEGIN
	select  
		 M.ClaveEmpleado as [Clave]
		,M.NOMBRECOMPLETO as [Nombre Empleado]
		,CASE
			WHEN M.Sexo = 'MASCULINO' THEN 'PADRE'
			WHEN M.Sexo = 'FEMENINO' THEN 'MADRE'
			ELSE 'NO ESPECIFICADO'
		END as [Paternidad Empleado]
		,M.Departamento as [Departamento]
		,M.Puesto as [Puesto]
		,M.Sucursal as [Sucursal]
		,count(fbe.IDEmpleado) as [Num Hijos]
		from [RH].[TblFamiliaresBenificiariosEmpleados] fbe
		join [RH].[TblCatParentescos] cp on fbe.IDParentesco = cp.IDParentesco
		join RH.tblEmpleadosMaster M on m.IDEmpleado = fbe.IDEmpleado
		left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario =@IDUsuario
		Where 
		 fbe.IDParentesco in (4,5) 
		and (( M.IDEmpleado = @FiltroEmpleado or @FiltroEmpleado = 0)
		and ( M.Departamento = @FiltroDepartamento or @FiltroDepartamento = 0)
		and ( M.IDPuesto = @FiltroPuesto or @FiltroPuesto = 0)
		and ( M.IDTipoPrestacion = @FiltroPrestaciones or @FiltroPrestaciones = 0)
		and ( M.IDCliente = @FiltroClientes or @FiltroClientes = 0)
		and ( M.IDTipoContrato = @FiltroTiposContratacion or @FiltroTiposContratacion = 0)
		and ( M.IDRazonSocial = @FiltroRazonesSociales or @FiltroRazonesSociales = 0)
		and ( M.IDTipoNomina = @FiltroDivisiones or @FiltroDivisiones = 0))
		group by
		M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,M.Sexo
		,M.Departamento
		,M.Puesto
		,M.Sucursal

	END

END
GO
