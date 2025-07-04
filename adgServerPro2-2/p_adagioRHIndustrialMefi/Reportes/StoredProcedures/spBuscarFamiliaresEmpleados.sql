USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarFamiliaresEmpleados] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
		,@IdiomaSQL varchar(100) = null
		,@dtEmpleados [RH].[dtEmpleados]
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
	
	;   

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	
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
			,M.Sexo as [Sexo Empleado]
			,M.Departamento as [Departamento]
			,M.Puesto as [Puesto]
			,M.Sucursal as [Sucursal]
			,JSON_VALUE(cp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [Parentesco]
			,fbe.NombreCompleto as [Nombre del Familiar/Beneficiario]
			,FORMAT(fbe.FechaNacimiento,'dd/MM/yyyy')  as [Fecha de Nacimiento Familiar/Beneficiario]
			,DATEDIFF(hour,fbe.FechaNacimiento,GETDATE())/8766 AS [Edad Familiar/Beneficiario]
			,IIF(fbe.Beneficiario = 1, 'Si', 'No') as [¿Beneficiario?]
			,fbe.Porcentaje as [Porcentaje]
		from [RH].[TblFamiliaresBenificiariosEmpleados] fbe
			join [RH].[TblCatParentescos] cp on fbe.IDParentesco = cp.IDParentesco
			join RH.tblEmpleadosMaster M on m.IDEmpleado = fbe.IDEmpleado
			left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario =@IDUsuario
		Where M.Vigente=1 
			and ( M.IDEmpleado = @FiltroEmpleado or @FiltroEmpleado = 0)
			and ( M.Departamento = @FiltroDepartamento or @FiltroDepartamento = 0)
			and ( M.IDPuesto = @FiltroPuesto or @FiltroPuesto = 0)
			and ( M.IDTipoPrestacion = @FiltroPrestaciones or @FiltroPrestaciones = 0)
			and ( M.IDCliente = @FiltroClientes or @FiltroClientes = 0)
			and ( M.IDTipoContrato = @FiltroTiposContratacion or @FiltroTiposContratacion = 0)
			and ( M.IDRazonSocial = @FiltroRazonesSociales or @FiltroRazonesSociales = 0)
			and ( M.IDTipoNomina = @FiltroDivisiones or @FiltroDivisiones = 0)

	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN

		select 
			 M.ClaveEmpleado as [Clave]
			,M.NOMBRECOMPLETO as [Nombre Empleado]
			,M.Sexo as [Sexo Empleado]
			,M.Departamento as [Departamento]
			,M.Puesto as [Puesto]
			,M.Sucursal as [Sucursal]
			,JSON_VALUE(cp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))as [Parentesco]
			,fbe.NombreCompleto as [Nombre del Familiar/Beneficiario]
			,FORMAT(fbe.FechaNacimiento,'dd/MM/yyyy')  as [Fecha de Nacimiento Familiar/Beneficiario]
			,DATEDIFF(hour,fbe.FechaNacimiento,GETDATE())/8766 AS [Edad Familiar/Beneficiario]
			,IIF(fbe.Beneficiario = 1, 'Si', 'No') as [¿Beneficiario?]
			,fbe.Porcentaje as [Porcentaje]
		from [RH].[TblFamiliaresBenificiariosEmpleados] fbe
			join [RH].[TblCatParentescos] cp on fbe.IDParentesco = cp.IDParentesco
			join RH.tblEmpleadosMaster M on m.IDEmpleado = fbe.IDEmpleado
			left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario =@IDUsuario
		Where m.Vigente=2
			and ( M.IDEmpleado = @FiltroEmpleado or @FiltroEmpleado = 0)
			and ( M.Departamento = @FiltroDepartamento or @FiltroDepartamento = 0)
			and ( M.IDPuesto = @FiltroPuesto or @FiltroPuesto = 0)
			and ( M.IDTipoPrestacion = @FiltroPrestaciones or @FiltroPrestaciones = 0)
			and ( M.IDCliente = @FiltroClientes or @FiltroClientes = 0)
			and ( M.IDTipoContrato = @FiltroTiposContratacion or @FiltroTiposContratacion = 0)
			and ( M.IDRazonSocial = @FiltroRazonesSociales or @FiltroRazonesSociales = 0)
			and ( M.IDTipoNomina = @FiltroDivisiones or @FiltroDivisiones = 0)

	END 
	ELSE IF(@IDTipoVigente = 3)
	BEGIN
		select 
			 M.ClaveEmpleado as [Clave]
			,M.NOMBRECOMPLETO as [Nombre Empleado]
			,M.Sexo as [Sexo Empleado]
			,M.Departamento as [Departamento]
			,M.Puesto as [Puesto]
			,M.Sucursal as [Sucursal]
			,JSON_VALUE(cp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [Parentesco]
			,fbe.NombreCompleto as [Nombre del Familiar/Beneficiario]
			,FORMAT(fbe.FechaNacimiento,'dd/MM/yyyy')  as [Fecha de Nacimiento Familiar/Beneficiario]
			,DATEDIFF(hour,fbe.FechaNacimiento,GETDATE())/8766 AS [Edad Familiar/Beneficiario]
			,IIF(fbe.Beneficiario = 1, 'Si', 'No') as [¿Beneficiario?]
			,fbe.Porcentaje as [Porcentaje]
		from [RH].[TblFamiliaresBenificiariosEmpleados] fbe
			join [RH].[TblCatParentescos] cp on fbe.IDParentesco = cp.IDParentesco
			join RH.tblEmpleadosMaster M on m.IDEmpleado = fbe.IDEmpleado
			left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario =@IDUsuario
		Where ( M.IDEmpleado = @FiltroEmpleado or @FiltroEmpleado = 0)
			and ( M.Departamento = @FiltroDepartamento or @FiltroDepartamento = 0)
			and ( M.IDPuesto = @FiltroPuesto or @FiltroPuesto = 0)
			and ( M.IDTipoPrestacion = @FiltroPrestaciones or @FiltroPrestaciones = 0)
			and ( M.IDCliente = @FiltroClientes or @FiltroClientes = 0)
			and ( M.IDTipoContrato = @FiltroTiposContratacion or @FiltroTiposContratacion = 0)
			and ( M.IDRazonSocial = @FiltroRazonesSociales or @FiltroRazonesSociales = 0)
			and ( M.IDTipoNomina = @FiltroDivisiones or @FiltroDivisiones = 0)
	END

	/*if(@IDTipoVigente = 1)
	BEGIN
			insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario
		
		
		
		
		SET
	@cols = STUFF(
		(
			SELECT
				DISTINCT ',' + QUOTENAME(
					concat(
						tb.pardesc,
						IIF(tb.rn > 1, CAST(tb.rn as varchar(max)), '')
					)
				)
			FROM
				(
					SELECT
						cp.Descripcion as pardesc,
						Row_Number() OVER (
							PARTITION BY fbe.IDEmpleado,
							fbe.IDParentesco
							order by
								fbe.IDParentesco
						) as rn
					FROM
						[RH].[TblFamiliaresBenificiariosEmpleados] fbe
						join [RH].[TblCatParentescos] cp on fbe.IDParentesco = cp.IDParentesco
						join RH.tblEmpleadosMaster M on m.IDEmpleado = fbe.IDEmpleado
						left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario =@IDUsuario
							Where 
								m.Vigente=1 
								and ( M.IDEmpleado = @FiltroEmpleado or @FiltroEmpleado = 0)
								and ( M.Departamento = @FiltroDepartamento or @FiltroDepartamento = 0)
								and ( M.IDPuesto = @FiltroPuesto or @FiltroPuesto = 0)
								and ( M.IDTipoPrestacion = @FiltroPrestaciones or @FiltroPrestaciones = 0)
								and ( M.IDCliente = @FiltroClientes or @FiltroClientes = 0)
								and ( M.IDTipoContrato = @FiltroTiposContratacion or @FiltroTiposContratacion = 0)
								and ( M.IDRazonSocial = @FiltroRazonesSociales or @FiltroRazonesSociales = 0)
								and ( M.IDTipoNomina = @FiltroDivisiones or @FiltroDivisiones = 0)
				) tb FOR XML PATH(''),
				TYPE
		).value('.', 'nvarchar(max)'),
		1,
		1,
		''
	);
					--select @cols
	SET @query = 'SELECT M.ClaveEmpleado as [Clave Empleado],concat(M.Nombre,'' '',M.Paterno,'' '',M.Materno) as Empleado, '+@cols+'
					from
						(
							SELECT
								tb.NombreCompleto,
								tb.IDEmpleado,
								concat(tb.pardesc,IIF(tb.rn > 1, CAST(tb.rn as varchar(max)), '''')) as DescNum
							FROM
								(
									SELECT
										cp.Descripcion as pardesc,
										Row_Number() OVER (
											PARTITION BY fbe.IDEmpleado,
											fbe.IDParentesco
											order by
												fbe.IDParentesco
										) as rn,
										fbe.NombreCompleto,
										fbe.IDEmpleado
									FROM
										[RH].[TblFamiliaresBenificiariosEmpleados] fbe
										left join [RH].[TblCatParentescos] cp on fbe.IDParentesco = cp.IDParentesco
								) tb
						) x pivot (
							max(NombreCompleto) for DescNum in ('+@cols+')
						) p
				join RH.tblEmpleadosMaster M on m.IDEmpleado = P.IDEmpleado
				left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario ='+CAST(@IDUsuario as varchar(max)) +'

			Where 
				m.Vigente=1 
				and ( M.IDEmpleado = '+@FiltroEmpleado+' or '+@FiltroEmpleado+' = 0)
				and ( M.Departamento = '+@FiltroDepartamento+' or '+@FiltroDepartamento+' = 0)
				and ( M.IDPuesto = '+@FiltroPuesto+' or '+@FiltroPuesto+' = 0)
				and ( M.IDTipoPrestacion = '+@FiltroPrestaciones+' or '+@FiltroPrestaciones+' = 0)
				and ( M.IDCliente = '+@FiltroClientes+' or '+@FiltroClientes+' = 0)
				and ( M.IDTipoContrato = '+@FiltroTiposContratacion+' or '+@FiltroTiposContratacion+' = 0)
				and ( M.IDRazonSocial = '+@FiltroRazonesSociales+' or '+@FiltroRazonesSociales+' = 0)
				and ( M.IDTipoNomina = '+@FiltroDivisiones +'or '+@FiltroDivisiones+' = 0)

				order by M.ClaveEmpleado asc';

    EXECUTE (@query);
	--select @cols

	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
			insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		SET
	@cols = STUFF(
		(
			SELECT
				DISTINCT ',' + QUOTENAME(
					concat(
						tb.pardesc,
						IIF(tb.rn > 1, CAST(tb.rn as varchar(max)), '')
					)
				)
			FROM
				(
					SELECT
						cp.Descripcion as pardesc,
						Row_Number() OVER (
							PARTITION BY fbe.IDEmpleado,
							fbe.IDParentesco
							order by
								fbe.IDParentesco
						) as rn
					FROM
						[RH].[TblFamiliaresBenificiariosEmpleados] fbe
						join [RH].[TblCatParentescos] cp on fbe.IDParentesco = cp.IDParentesco
						join RH.tblEmpleadosMaster M on m.IDEmpleado = fbe.IDEmpleado
						left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
							Where 
								m.Vigente=1 
								and ( M.IDEmpleado = @FiltroEmpleado or @FiltroEmpleado = 0)
								and ( M.Departamento = @FiltroDepartamento or @FiltroDepartamento = 0)
								and ( M.IDPuesto = @FiltroPuesto or @FiltroPuesto = 0)
								and ( M.IDTipoPrestacion = @FiltroPrestaciones or @FiltroPrestaciones = 0)
								and ( M.IDCliente = @FiltroClientes or @FiltroClientes = 0)
								and ( M.IDTipoContrato = @FiltroTiposContratacion or @FiltroTiposContratacion = 0)
								and ( M.IDRazonSocial = @FiltroRazonesSociales or @FiltroRazonesSociales = 0)
								and ( M.IDTipoNomina = @FiltroDivisiones or @FiltroDivisiones = 0)
				) tb FOR XML PATH(''),
				TYPE
		).value('.', 'nvarchar(max)'),
		1,
		1,
		''
	);
					--select @cols



	SET @query = 'SELECT M.ClaveEmpleado as [Clave Empleado],concat(M.Nombre,'' '',M.Paterno,'' '',M.Materno) as Empleado, '+@cols+'
					from
						(
							SELECT
								tb.NombreCompleto,
								tb.IDEmpleado,
								concat(tb.pardesc,IIF(tb.rn > 1, CAST(tb.rn as varchar(max)), '''')) as DescNum
							FROM
								(
									SELECT
										cp.Descripcion as pardesc,
										Row_Number() OVER (
											PARTITION BY fbe.IDEmpleado,
											fbe.IDParentesco
											order by
												fbe.IDParentesco
										) as rn,
										fbe.NombreCompleto,
										fbe.IDEmpleado
									FROM
										[RH].[TblFamiliaresBenificiariosEmpleados] fbe
										join [RH].[TblCatParentescos] cp on fbe.IDParentesco = cp.IDParentesco
								) tb
						) x pivot (
							max(NombreCompleto) for DescNum in ('+@cols+')
						) p
						join RH.tblEmpleadosMaster M on m.IDEmpleado = P.IDEmpleado
				join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario ='+CAST(@IDUsuario as varchar(max)) +'
		
			Where 
				m.Vigente=0
				and ( M.IDEmpleado = '+@FiltroEmpleado+' or '+@FiltroEmpleado+' = 0)
				and ( M.Departamento = '+@FiltroDepartamento+' or '+@FiltroDepartamento+' = 0)
				and ( M.IDPuesto = '+@FiltroPuesto+' or '+@FiltroPuesto+' = 0)
				and ( M.IDTipoPrestacion = '+@FiltroPrestaciones+' or '+@FiltroPrestaciones+' = 0)
				and ( M.IDCliente = '+@FiltroClientes+' or '+@FiltroClientes+' = 0)
				and ( M.IDTipoContrato = '+@FiltroTiposContratacion+' or '+@FiltroTiposContratacion+' = 0)
				and ( M.IDRazonSocial = '+@FiltroRazonesSociales+' or '+@FiltroRazonesSociales+' = 0)
				and ( M.IDTipoNomina = '+@FiltroDivisiones +'or '+@FiltroDivisiones+' = 0)

				order by M.ClaveEmpleado asc';

    EXECUTE (@query);

	END 
	ELSE IF(@IDTipoVigente = 3)
	BEGIN
			insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		SET
	@cols = STUFF(
		(
			SELECT
				DISTINCT ',' + QUOTENAME(
					concat(
						tb.pardesc,
						IIF(tb.rn > 1, CAST(tb.rn as varchar(max)), '')
					)
				)
			FROM
				(
					SELECT
						cp.Descripcion as pardesc,
						Row_Number() OVER (
							PARTITION BY fbe.IDEmpleado,
							fbe.IDParentesco
							order by
								fbe.IDParentesco
						) as rn
					FROM
						[RH].[TblFamiliaresBenificiariosEmpleados] fbe
						join [RH].[TblCatParentescos] cp on fbe.IDParentesco = cp.IDParentesco
						join RH.tblEmpleadosMaster M on m.IDEmpleado = fbe.IDEmpleado
						left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
							Where 
								m.Vigente=1 
								and ( M.IDEmpleado = @FiltroEmpleado or @FiltroEmpleado = 0)
								and ( M.Departamento = @FiltroDepartamento or @FiltroDepartamento = 0)
								and ( M.IDPuesto = @FiltroPuesto or @FiltroPuesto = 0)
								and ( M.IDTipoPrestacion = @FiltroPrestaciones or @FiltroPrestaciones = 0)
								and ( M.IDCliente = @FiltroClientes or @FiltroClientes = 0)
								and ( M.IDTipoContrato = @FiltroTiposContratacion or @FiltroTiposContratacion = 0)
								and ( M.IDRazonSocial = @FiltroRazonesSociales or @FiltroRazonesSociales = 0)
								and ( M.IDTipoNomina = @FiltroDivisiones or @FiltroDivisiones = 0)
				) tb FOR XML PATH(''),
				TYPE
		).value('.', 'nvarchar(max)'),
		1,
		1,
		''
	);
					--select @cols



	SET @query = 'SELECT M.ClaveEmpleado as [Clave Empleado],concat(M.Nombre,'' '',M.Paterno,'' '',M.Materno) as Empleado, '+@cols+'
					from
						(
							SELECT
								tb.NombreCompleto,
								tb.IDEmpleado,
								concat(tb.pardesc,IIF(tb.rn > 1, CAST(tb.rn as varchar(max)), '''')) as DescNum
							FROM
								(
									SELECT
										cp.Descripcion as pardesc,
										Row_Number() OVER (
											PARTITION BY fbe.IDEmpleado,
											fbe.IDParentesco
											order by
												fbe.IDParentesco
										) as rn,
										fbe.NombreCompleto,
										fbe.IDEmpleado
									FROM
										[RH].[TblFamiliaresBenificiariosEmpleados] fbe
										join [RH].[TblCatParentescos] cp on fbe.IDParentesco = cp.IDParentesco
								) tb
						) x pivot (
							max(NombreCompleto) for DescNum in ('+@cols+')
						) p
						join RH.tblEmpleadosMaster M on m.IDEmpleado = P.IDEmpleado
				join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario ='+CAST(@IDUsuario as varchar(max)) +'
			Where 
				( M.IDEmpleado = '+@FiltroEmpleado+' or '+@FiltroEmpleado+' = 0)
				and ( M.Departamento = '+@FiltroDepartamento+' or '+@FiltroDepartamento+' = 0)
				and ( M.IDPuesto = '+@FiltroPuesto+' or '+@FiltroPuesto+' = 0)
				and ( M.IDTipoPrestacion = '+@FiltroPrestaciones+' or '+@FiltroPrestaciones+' = 0)
				and ( M.IDCliente = '+@FiltroClientes+' or '+@FiltroClientes+' = 0)
				and ( M.IDTipoContrato = '+@FiltroTiposContratacion+' or '+@FiltroTiposContratacion+' = 0)
				and ( M.IDRazonSocial = '+@FiltroRazonesSociales+' or '+@FiltroRazonesSociales+' = 0)
				and ( M.IDTipoNomina = '+@FiltroDivisiones +'or '+@FiltroDivisiones+' = 0)

				order by M.ClaveEmpleado asc';

    EXECUTE (@query);

	END */
END
GO
