USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [RH].[spCompararEmpleadoVsPosicion](
	@IDPosicion int,
	@IDEmpleado int,
	@IDUsuario int
) as
	declare 
		@Configuraciones varchar(max)
		,@IDPlazaActual				int
		,@IDPlazaNueva				int
		,@Cliente					varchar(max)
		,@Puesto					varchar(max)
		,@NivelEmpresarial			varchar(max)
		,@NivelSalarial				varchar(max)
		,@NuevoCliente				varchar(max)
		,@NuevoPuesto				varchar(max)
		,@NuevoNivelEmpresarial		varchar(max)
		,@NuevoNivelSalarial		varchar(max)
		,@PosicionJefe				varchar(max)
		,@Departamento				varchar(max)
		,@Sucursal					varchar(max)
		,@Prestaciones				varchar(max)
		,@RegistroPatronal			varchar(max)
		,@Empresa					varchar(max)
		,@CentroCosto				varchar(max)
		,@Area						varchar(max)
		,@Division					varchar(max)
		,@Region					varchar(max)
		,@ClasificacionCorporativa	varchar(max)
		,@Perfil					varchar(max)
        ,@TipoNomina                varchar(max)
	;

	DECLARE @IDIdioma VARCHAR(MAX);
	SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx');


	select
		@PosicionJefe				= isnull((select top 1 e.NombreCompleto 
												from RH.tblJefesEmpleados j 
													join RH.tblEmpleadosMaster e on e.IDEmpleado = j.IDJefe
												where j.IDEmpleado = @IDEmpleado
												order by j.Nivel asc
											), '[SIN ASIGAR]')
		-- ,@Cliente					= isnull(e.Cliente					, '[SIN ASIGNAR]')
		-- ,@Puesto					= isnull(e.Puesto					, '[SIN ASIGNAR]')
        ,@Cliente =isnull(JSON_VALUE(cliente.Traduccion, FORMATMESSAGE('$.%s.%s', 'esmx', 'NombreComercial')),'[SIN ASIGNAR]')
		,@Puesto = isnull(JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', 'esmx', 'Descripcion')),'[SIN ASIGNAR]')

		,@Departamento				= isnull(JSON_VALUE(departamento.Traduccion, FORMATMESSAGE('$.%s.%s', 'esmx', 'NombreComercial')),'[SIN ASIGNAR]')
		,@Sucursal					= isnull(e.Sucursal 				, '[SIN ASIGNAR]')
		,@Prestaciones				= isnull(e.TiposPrestacion 			, '[SIN ASIGNAR]')
		,@RegistroPatronal			= isnull(e.RegPatronal 				, '[SIN ASIGNAR]')
		,@Empresa					= isnull(e.Empresa 				, '[SIN ASIGNAR]')
		,@CentroCosto				= isnull(JSON_VALUE(centrocosto.Traduccion, FORMATMESSAGE('$.%s.%s', 'esmx', 'Descripcion')),'[SIN ASIGNAR]')
		,@Area						= isnull(JSON_VALUE(area.Traduccion, FORMATMESSAGE('$.%s.%s', 'esmx', 'Descripcion')), '[SIN ASIGNAR]')
		,@Division					= isnull(e.Division 				, '[SIN ASIGNAR]')
		,@Region					= isnull(JSON_VALUE(region.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion'))	, '[SIN ASIGNAR]')
		,@ClasificacionCorporativa	= isnull(e.ClasificacionCorporativa	, '[SIN ASIGNAR]')
        ,@TipoNomina = isnull(e.TipoNomina	, '[SIN ASIGNAR]')
		,@Perfil					= isnull((
										select p.Descripcion
										from Seguridad.tblUsuarios u
											join Seguridad.tblCatPerfiles p on p.IDPerfil = u.IDPerfil
										where u.IDEmpleado = @IDEmpleado
									), '[SIN ASIGNAR]')
	from RH.tblEmpleadosMaster e
        left join RH.tblCatClientes cliente on cliente.IDCliente = e.IDcliente
		left join RH.tblCatPuestos puesto	on puesto.IDPuesto = e.IDPuesto
        left join RH.tblCatCentroCosto centrocosto on centrocosto.IDCentroCosto=e.IDCentroCosto
        left join RH.tblCatDepartamentos departamento on departamento.IDDepartamento=e.IDDepartamento
        left join RH.tblCatArea area on area.IDArea = e.IDArea
        left join RH.tblCatRegiones region on region.IDRegion = e.IDRegion
	where e.IDEmpleado = @IDEmpleado

 

	declare @TempCatTipoFiltro as table(
		Filtro varchar(255) COLLATE database_default
		,Descripcion varchar(255) COLLATE database_default
	)

	insert into @TempCatTipoFiltro(Filtro, Descripcion)
	values
		('Cliente'						, 'Cliente')
		,('Empresa'						, 'Razón social')
		,('RegistroPatronal'			, 'Registro patronal')
		,('CentroCosto'					, 'Centro de costo')
		,('Departamento'				, 'Departamento')
		,('Area'						, 'Área')
		,('Puesto'						, 'Puesto')
		,('Prestaciones'				, 'Prestaciones')
		,('Sucursal'					, 'Sucursal')
		,('Division'					, 'División')
		,('Region'						, 'Región')
		,('ClasificacionCorporativa'	, 'Clasificación corporativa')
		,('TiposContratacion'			, 'Tipos de contratación')
		,('TiposNomina'					, 'Tipos de nómina')
		,('PosicionJefe'				, 'Manager')
		,('Perfil'						, 'Perfil')
		,('NivelEmpresarial'			, 'Nivel Empresarial')
		,('NivelSalarial'				, 'Nivel Salarial')
        ,('TipoNomina'				, 'Tipo de Nómina')

		--,('IncidenciasAusentismos'    , 'Incidencias/Ausentismos'			)
		--,('Empleados'					, 'Colaboradores'					)
		--,('Excluir Empleado'			, 'Excluir un colaborador'			)
		--,('Solo Vigentes'				, 'Solo colaboradores vigentes'		)
		--,('Usuarios'					, 'Usuarios'						)
		--,('Excluir Usuarios'			, 'Excluir un usuario'				)
		--,('Subordinados'				, 'Subordinados'					)


	select 
		-- @Cliente =isnull(JSON_VALUE(cliente.Traduccion, FORMATMESSAGE('$.%s.%s', 'esmx', 'NombreComercial')),'[SIN ASIGNAR]')
		-- ,@Puesto = isnull(JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', 'esmx', 'Descripcion')),'[SIN ASIGNAR]')
		@NivelSalarial = case when isnull(tabulador.IDNivelSalarial, 0) = 0 then '[SIN ASIGNAR]'
							else FORMATMESSAGE('%s Min: %s - Max: %s', tabulador.Nombre, FORMAT(tabulador.Minimo, 'N2'), FORMAT(tabulador.Maximo, 'N2'))
						end
		,@NivelEmpresarial = case when isnull(niveles.IDNivelEmpresarial, 0) = 0 then '[SIN ASIGNAR]' 
								else FORMATMESSAGE('%s - %i', niveles.Nombre, niveles.Orden)
							end
	from RH.tblCatPosiciones po
		join RH.tblCatPlazas p				on p.IDPlaza = po.IDPlaza
		left join RH.tblCatClientes cliente on cliente.IDCliente = p.IDcliente
		left join RH.tblCatPuestos puesto	on puesto.IDPuesto = p.IDPuesto
		left join RH.tblTabuladorSalarial tabulador		on tabulador.IDNivelSalarial = p.IDNivelSalarial
		left join RH.tblCatNivelesEmpresariales niveles on niveles.IDNivelEmpresarial = p.IDNivelEmpresarial
	where po.IDEmpleado = @IDEmpleado



	select 
		@Configuraciones = p.Configuraciones
		,@NuevoCliente =isnull(JSON_VALUE(cliente.Traduccion, FORMATMESSAGE('$.%s.%s', 'esmx', 'NombreComercial')),'[SIN ASIGNAR]')
		,@NuevoPuesto = isnull(JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', 'esmx', 'Descripcion')),'[SIN ASIGNAR]')
		,@NuevoNivelSalarial = case when isnull(tabulador.IDNivelSalarial, 0) = 0 then '[SIN ASIGNAR]'
									else FORMATMESSAGE('%s Min: %s - Max: %s', tabulador.Nombre, FORMAT(tabulador.Minimo, 'N2'), FORMAT(tabulador.Maximo, 'N2'))
								end
		,@NuevoNivelEmpresarial = case when isnull(niveles.IDNivelEmpresarial, 0) = 0 then '[SIN ASIGNAR]' 
									else FORMATMESSAGE('%s - %i', niveles.Nombre, niveles.Orden)
								end
	from RH.tblCatPosiciones po
		join RH.tblCatPlazas p				on p.IDPlaza = po.IDPlaza
		left join RH.tblCatClientes cliente on cliente.IDCliente = p.IDcliente
		left join RH.tblCatPuestos puesto	on puesto.IDPuesto = p.IDPuesto
		left join RH.tblTabuladorSalarial tabulador		on tabulador.IDNivelSalarial = p.IDNivelSalarial
		left join RH.tblCatNivelesEmpresariales niveles on niveles.IDNivelEmpresarial = p.IDNivelEmpresarial
	where po.IDPosicion = @IDPosicion


	declare @tblComparacionHistoriales as table (
		IDFiltro varchar(200),
		Filtro varchar(200),
		Actual varchar(500),
        IDNuevo int ,
		Nuevo varchar(500),
		Distinto bit
	);

	insert @tblComparacionHistoriales(IDFiltro, Nuevo , IDNuevo)
	select 
		IDTipoConfiguracionPlaza,
		case 
			when IDTipoConfiguracionPlaza = 'PosicionJefe'				then isnull((select e.NombreCompleto 
																					from RH.tblCatPosiciones p 
																						join RH.tblEmpleadosMaster e on e.IDEmpleado = p.IDEmpleado
																					where p.IDPosicion = config.Valor), '[SIN ASIGAR]')
			when IDTipoConfiguracionPlaza = 'Departamento'				then isnull((select dep.Descripcion			from RH.tblCatDepartamentos dep			where dep.IDDepartamento		= config.Valor), '[SIN ASIGNAR]') 
			when IDTipoConfiguracionPlaza = 'Sucursal'					then isnull((select suc.Descripcion			from RH.tblCatSucursales suc			where suc.IDSucursal			= config.Valor), '[SIN ASIGNAR]') 
			when IDTipoConfiguracionPlaza = 'Prestaciones'				then isnull((select tpres.Descripcion		from RH.tblCatTiposPrestaciones tpres	where tpres.IDTipoPrestacion	= config.Valor), '[SIN ASIGNAR]') 
			when IDTipoConfiguracionPlaza = 'RegistroPatronal'			then isnull((select reg.RazonSocial			from RH.tblCatRegPatronal reg			where reg.IDRegPatronal			= config.Valor), '[SIN ASIGNAR]') 
			-- when IDTipoConfiguracionPlaza = 'Empresa'					then isnull((select emp.RazonSocial			from RH.tblCatRazonesSociales emp		where emp.IDRazonSocial			= config.Valor), '[SIN ASIGNAR]') 
            when IDTipoConfiguracionPlaza = 'Empresa'					then isnull((select emp.NombreComercial			from RH.tblEmpresa emp		where emp.IDEmpresa = config.Valor), '[SIN ASIGNAR]')              
			when IDTipoConfiguracionPlaza = 'CentroCosto'				then isnull((select cent.Descripcion		from RH.tblCatCentroCosto cent			where cent.IDCentroCosto		= config.Valor), '[SIN ASIGNAR]') 
			when IDTipoConfiguracionPlaza = 'Area'						then isnull((select area.Descripcion		from RH.tblCatArea area					where area.IDArea				= config.Valor),'[SIN ASIGNAR]') 
			when IDTipoConfiguracionPlaza = 'Division'					then isnull((select divs.Descripcion		from RH.tblCatDivisiones divs			where divs.IDDivision			= config.Valor),'[SIN ASIGNAR]') 
			when IDTipoConfiguracionPlaza = 'Region'					then isnull((select tregions.Descripcion	from RH.tblCatRegiones tregions			where tregions.IDRegion			= config.Valor),'[SIN ASIGNAR]') 
			--when IDTipoConfiguracionPlaza = 'ClasificacionCorporativa'	then isnull((select clasf.Descripcion		from RH.tblCatClasificacionesCorporativas clasf where clasf.IDClasificacionCorporativa = config.Valor),'[SIN ASIGNAR]') 
			when IDTipoConfiguracionPlaza = 'ClasificacionCorporativa'	then isnull((select JSON_VALUE(clasf.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')) from RH.tblCatClasificacionesCorporativas clasf where clasf.IDClasificacionCorporativa = config.Valor),'[SIN ASIGNAR]') 
			when IDTipoConfiguracionPlaza = 'Perfil'					then isnull((select perfil.Descripcion		from Seguridad.tblCatPerfiles  perfil	where perfil.IDPerfil			= config.Valor),'[SIN ASIGNAR]')                                                               
            when IDTipoConfiguracionPlaza = 'TipoNomina' then isnull((select tNomina.Descripcion from Nomina.tblCatTipoNomina  tNomina where tNomina.IDTipoNomina=Valor),'[SIN ASIGNAR]')                                                               
		else '[SIN ASIGAR]' end as Descripcion,
        isnull(Valor,0) 
	from OPENJSON(@Configuraciones, '$') 
	with (
		IDTipoConfiguracionPlaza varchar(max), 
		Valor int
	) as config
 
	insert @tblComparacionHistoriales(IDFiltro, Nuevo) 
	values
		('Cliente'			,isnull(@NuevoCliente,			'[SIN ASIGNAR]')) 
		,('Puesto'			,isnull(@NuevoPuesto,			'[SIN ASIGNAR]'))
		,('NivelEmpresarial',isnull(@NuevoNivelEmpresarial, '[SIN ASIGNAR]'))                                 
		,('NivelSalarial'	,isnull(@NuevoNivelSalarial,	'[SIN ASIGNAR]'))   

	update ch
		set
			ch.Filtro = tf.Descripcion,
			Actual = case 
						when ch.IDFiltro = 'Cliente'					then isnull(@Cliente					, '[SIN ASIGNAR]') 
						when ch.IDFiltro = 'Puesto'						then isnull(@Puesto						, '[SIN ASIGNAR]') 
						when ch.IDFiltro = 'PosicionJefe'				then isnull(@PosicionJefe				, '[SIN ASIGNAR]')
						when ch.IDFiltro = 'Departamento'				then isnull(@Departamento				, '[SIN ASIGNAR]')
						when ch.IDFiltro = 'Sucursal'					then isnull(@Sucursal					, '[SIN ASIGNAR]')
						when ch.IDFiltro = 'Prestaciones'				then isnull(@Prestaciones				, '[SIN ASIGNAR]')
						when ch.IDFiltro = 'RegistroPatronal'			then isnull(@RegistroPatronal			, '[SIN ASIGNAR]')
						when ch.IDFiltro = 'Empresa'					then isnull(@Empresa					, '[SIN ASIGNAR]')
						when ch.IDFiltro = 'CentroCosto'				then isnull(@CentroCosto				, '[SIN ASIGNAR]')
						when ch.IDFiltro = 'Area'						then isnull(@Area						, '[SIN ASIGNAR]')
						when ch.IDFiltro = 'Division'					then isnull(@Division					, '[SIN ASIGNAR]')
						when ch.IDFiltro = 'Region'						then isnull(@Region						, '[SIN ASIGNAR]')
						when ch.IDFiltro = 'ClasificacionCorporativa'	then isnull(@ClasificacionCorporativa	, '[SIN ASIGNAR]')
						when ch.IDFiltro = 'Perfil'						then isnull(@Perfil						, '[SIN ASIGNAR]')
						when ch.IDFiltro = 'NivelEmpresarial'			then isnull(@NivelEmpresarial			, '[SIN ASIGNAR]')                                 
						when ch.IDFiltro = 'NivelSalarial'				then isnull(@NivelSalarial				, '[SIN ASIGNAR]')   
                        when ch.IDFiltro = 'TipoNomina'				then isnull(@TipoNomina				, '[SIN ASIGNAR]')  
					else '[SIN ASIGAR]' end
	from @tblComparacionHistoriales ch
		left join @TempCatTipoFiltro tf on tf.Filtro = ch.IDFiltro

	update @tblComparacionHistoriales
		set Distinto = case
							when isnull(@IDEmpleado, 0) = 0 then cast(0 as bit)
							when Actual = '[SIN ASIGAR]' and	Nuevo = '[SIN ASIGAR]' then cast(0 as bit)
							when Actual = '[SIN ASIGAR]' or		Nuevo = '[SIN ASIGAR]' then cast(1 as bit)
							when Actual != Nuevo then cast(1 as bit)
						else cast(0 as bit) end

	select 
		IDFiltro,
		Filtro,
        isnull(IDNuevo,0) as IDNuevo, -- aplica solamente para las configuracion, si se llegase a necesitar los datos (Cliente,NivelSalarial,NivelEmpresarial,Puesto), obtenerse de la tabla en sus respectivas columnas -Jose Vargas
		Actual,
		Nuevo,
		Distinto
	from @tblComparacionHistoriales ch
	order by Distinto desc, Filtro
GO
