USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca trabajadores según la opción que recibe por parámetro.
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-07-05
** Paremetros		:  
		@tipo    -1 : Todos los empleados
				  0  : Empleados Vigentes
				  1  : Empleados No Vigentes
				  2  : Cumpleaños hoy
				  3  : Cumpleaños en un fecha Específica   
				  4	 : Cumpleaños durante los proximos 5 dias
                  5  : Empleados Subordinados (Jefe-Empleado) -  INTRANET
                  6  : Empleados con Filtro Usuario (Empleados-Usuarios-Filtros) -  INTRANET
				  7	 : Cumpleaños hoy (ConfiguracionGeneral filtrado por cliente o todos)
				  8	 : Cumpleaños durante los proximos 5 dias (ConfiguracionGeneral filtrado por cliente o todos)
EXEC [RH].[spBuscarEmpleadosTipo]@IDUsuario = 1, @query = null, @tipo = 2        
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
2020-06-01			Jose Roman		Se agrega columna para la cantidad de solicitudes pendientes
									que tiene un colaborador en la intranet.
2021-07-30			Aneudy Abreu	Se agregó paginación y orden por columna
2022-08-05          Jose Vargas     Se quito el join Seguridad.tblDetalleFiltrosEmpleadosUsuarios para 
                                    Los tipos 2,3 y 4
2022-11-15          Jose Vargas     Se remplazan en la busqueda "FREETEXT" por "CONTAINS", por que no estaba 
                                    funcionando con las claves de empleados
2023-08-07			Econtreras		Se agrega el filtrado para que respete la configuración Por Clinte/General
***************************************************************************************************/

/*
[RH].[spBuscarEmpleadosTipo] @tipo = 2,@Fecha= '2024-02-14', @IDUsuario = 1, @PageSize = 20
*/

CREATE proc [RH].[spBuscarEmpleadosTipo]( 
	@tipo		int
	,@fecha		date = null
	,@IDUsuario int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'ClaveEmpleado'
	,@orderDirection varchar(4) = 'asc'
)
as
	

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	   ,@IDEmpleado int = 0
	   ,@Valor varchar(25) = ''
	   ,@IDCliente int = 0;
	;
	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	select @IDEmpleado = IDEmpleado from Seguridad.tblUsuarios with(nolock) where IDUsuario = @IDUsuario   

	select @Valor = Valor 
	from App.tblConfiguracionesGenerales cg with(nolock)
	where cg.IDConfiguracion = 'FiltroCumpleañoIntranet'

	select @IDCliente = IDCliente from RH.tblEmpleadosMaster with(nolock) where IDEmpleado = @IDEmpleado 

	declare @ResponseEmpleados as table (
		[IDEmpleado] [int] NULL,
		[ClaveEmpleado] [varchar](20) NULL,
		[RFC] [varchar](20) NULL,
		[CURP] [varchar](20) NULL,
		[IMSS] [varchar](20) NULL,
		[Nombre] [varchar](50) NULL,
		[SegundoNombre] [varchar](50) NULL,
		[Paterno] [varchar](50) NULL,
		[Materno] [varchar](50) NULL,
		[NOMBRECOMPLETO] [varchar](500) NULL,
		[IDLocalidadNacimiento] [int] NULL,
		[LocalidadNacimiento] [varchar](100) NULL,
		[IDMunicipioNacimiento] [int] NULL,
		[MunicipioNacimiento] [varchar](100) NULL,
		[IDEstadoNacimiento] [int] NULL,
		[EstadoNacimiento] [varchar](100) NULL,
		[IDPaisNacimiento] [int] NULL,
		[PaisNacimiento] [varchar](100) NULL,
		[FechaNacimiento] [date] NULL,
		[IDEstadoCiviL] [int] NULL,
		[EstadoCivil] [varchar](100) NULL,
		[Sexo] [varchar](15) NULL,
		[IDEscolaridad] [int] NULL,
		[Escolaridad] [varchar](100) NULL,
		[DescripcionEscolaridad] [varchar](100) NULL,
		[IDInstitucion] [int] NULL,
		[Institucion] [varchar](100) NULL,
		[IDProbatorio] [int] NULL,
		[Probatorio] [varchar](100) NULL,
		[FechaPrimerIngreso] [date] NULL,
		[FechaIngreso] [date] NULL,
		[FechaAntiguedad] [date] NULL,
		[Sindicalizado] [bit] NULL,
		[IDJornadaLaboral] [int] NULL,
		[JornadaLaboral] [varchar](100) NULL,
		[UMF] [varchar](10) NULL,
		[CuentaContable] [varchar](50) NULL,
		[IDTipoRegimen] [int] NULL,
		[TipoRegimen] [varchar](200) NULL,
		[IDPreferencia] [int] NULL,
		[IDDepartamento] [int] NULL,
		[Departamento] [varchar](500) NULL,
		[IDSucursal] [int] NULL,
		[Sucursal] [varchar](500) NULL,
		[IDPuesto] [int] NULL,
		[Puesto] [varchar](500) NULL,
		[IDCliente] [int] NULL,
		[Cliente] [varchar](500) NULL,
		[IDEmpresa] [int] NULL,
		[Empresa] [varchar](500) NULL,
		[IDCentroCosto] [int] NULL,
		[CentroCosto] [varchar](500) NULL,
		[IDArea] [int] NULL,
		[Area] [varchar](500) NULL,
		[IDDivision] [int] NULL,
		[Division] [varchar](500) NULL,
		[IDRegion] [int] NULL,
		[Region] [varchar](500) NULL,
		[IDClasificacionCorporativa] [int] NULL,
		[ClasificacionCorporativa] [varchar](500) NULL,
		[IDRegPatronal] [int] NULL,
		[RegPatronal] [varchar](500) NULL,
		[IDTipoNomina] [int] NULL,
		[TipoNomina] [varchar](500) NULL,
		[SalarioDiario] [decimal](18, 2) NULL,
		[SalarioDiarioReal] [decimal](18, 2) NULL,
		[SalarioIntegrado] [decimal](18, 2) NULL,
		[SalarioVariable] [decimal](18, 2) NULL,
		[IDTipoPrestacion] [int] NULL,
		[IDRazonSocial] [int] NULL,
		[RazonSocial] [varchar](500) NULL,
		[IDAfore] [int] NULL,
		[Afore] [varchar](max) NULL,
		[Vigente] [bit] NULL,
		[RowNumber] [int] NULL,
		[ClaveNombreCompleto] [varchar](500) NOT NULL,
		[PermiteChecar] [bit] NULL,
		[RequiereChecar] [bit] NULL,
		[PagarTiempoExtra] [bit] NULL,
		[PagarPrimaDominical] [bit] NULL,
		[PagarDescansoLaborado] [bit] NULL,
		[PagarFestivoLaborado] [bit] NULL,
		[IDDocumento] [int] NULL,
		[Documento] [varchar](max) NULL,
		[IDTipoContrato] [int] NULL,
		[TipoContrato] [varchar](max) NULL,
		[FechaIniContrato] [date] NULL,
		[FechaFinContrato] [date] NULL,
		[TiposPrestacion] [varchar](max) NULL,
		[tipoTrabajadorEmpleado] [varchar](max) NULL,
		SolicitudesPendientes int
	)

	if (@tipo in (-1, 0, 1))
	begin
		insert @ResponseEmpleados
		select 
			em.IDEmpleado
			,em.ClaveEmpleado
			,em.RFC
			,em.CURP
			,em.IMSS
			,em.Nombre
			,em.SegundoNombre
			,em.Paterno
			,em.Materno
			,em.NOMBRECOMPLETO
			,em.IDLocalidadNacimiento
			,em.LocalidadNacimiento
			,em.IDMunicipioNacimiento
			,em.MunicipioNacimiento
			,em.IDEstadoNacimiento
			,em.EstadoNacimiento
			,em.IDPaisNacimiento
			,em.PaisNacimiento
			,em.FechaNacimiento
			,em.IDEstadoCiviL
			,em.EstadoCivil
			,em.Sexo
			,em.IDEscolaridad
			,em.Escolaridad
			,em.DescripcionEscolaridad
			,em.IDInstitucion
			,em.Institucion
			,em.IDProbatorio
			,em.Probatorio
			,em.FechaPrimerIngreso
			,em.FechaIngreso
			,em.FechaAntiguedad
			,em.Sindicalizado
			,em.IDJornadaLaboral
			,em.JornadaLaboral
			,em.UMF
			,em.CuentaContable
			,em.IDTipoRegimen
			,em.TipoRegimen
			,em.IDPreferencia
			,em.IDDepartamento
			,em.Departamento
			,em.IDSucursal
			,em.Sucursal
			,em.IDPuesto
			,em.Puesto
			,em.IDCliente
			,em.Cliente
			,em.IDEmpresa
			,em.Empresa
			,em.IDCentroCosto
			,em.CentroCosto
			,em.IDArea
			,em.Area
			,em.IDDivision
			,em.Division
			,em.IDRegion
			,em.Region
			,em.IDClasificacionCorporativa
			,em.ClasificacionCorporativa
			,em.IDRegPatronal
			,em.RegPatronal
			,em.IDTipoNomina
			,em.TipoNomina
			,em.SalarioDiario
			,em.SalarioDiarioReal
			,em.SalarioIntegrado
			,em.SalarioVariable
			,em.IDTipoPrestacion
			,em.IDRazonSocial
			,em.RazonSocial
			,em.IDAfore
			,em.Afore
			,em.Vigente
			,em.RowNumber
			,em.ClaveNombreCompleto
			,em.PermiteChecar
			,em.RequiereChecar
			,em.PagarTiempoExtra
			,em.PagarPrimaDominical
			,em.PagarDescansoLaborado
			,em.PagarFestivoLaborado
			,em.IDDocumento
			,em.Documento
			,em.IDTipoContrato
			,em.TipoContrato
			,em.FechaIniContrato
			,em.FechaFinContrato
			,em.TiposPrestacion
			,em.tipoTrabajadorEmpleado
			,(Select count(*) 
				from Intranet.tblSolicitudesEmpleado with(nolock)
				where IDEmpleado = em.IDEmpleado and IDEstatusSolicitud = 1 -- PENDIENTES
			) as SolicitudesPendientes	     
		from [RH].[tblEmpleadosMaster] em with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where em.Vigente = case 
								when @tipo = -1 then em.Vigente
								when @tipo = 0 then 1
								when @tipo = 1 then 0
								else em.Vigente end
				and (@query = '""' or contains(em.*, @query)) 
	end;

    if (@tipo = 2)
    begin
		print 'Cumpleaños hoy'
 
		insert @ResponseEmpleados
		select 
			em.IDEmpleado
			,em.ClaveEmpleado
			,em.RFC
			,em.CURP
			,em.IMSS
			,em.Nombre
			,em.SegundoNombre
			,em.Paterno
			,em.Materno
			,em.NOMBRECOMPLETO
			,em.IDLocalidadNacimiento
			,em.LocalidadNacimiento
			,em.IDMunicipioNacimiento
			,em.MunicipioNacimiento
			,em.IDEstadoNacimiento
			,em.EstadoNacimiento
			,em.IDPaisNacimiento
			,em.PaisNacimiento
			,em.FechaNacimiento
			,em.IDEstadoCiviL
			,em.EstadoCivil
			,em.Sexo
			,em.IDEscolaridad
			,em.Escolaridad
			,em.DescripcionEscolaridad
			,em.IDInstitucion
			,em.Institucion
			,em.IDProbatorio
			,em.Probatorio
			,em.FechaPrimerIngreso
			,em.FechaIngreso
			,em.FechaAntiguedad
			,em.Sindicalizado
			,em.IDJornadaLaboral
			,em.JornadaLaboral
			,em.UMF
			,em.CuentaContable
			,em.IDTipoRegimen
			,em.TipoRegimen
			,em.IDPreferencia
			,em.IDDepartamento
			,em.Departamento
			,em.IDSucursal
			,em.Sucursal
			,em.IDPuesto
			,em.Puesto
			,em.IDCliente
			,em.Cliente
			,em.IDEmpresa
			,em.Empresa
			,em.IDCentroCosto
			,em.CentroCosto
			,em.IDArea
			,em.Area
			,em.IDDivision
			,em.Division
			,em.IDRegion
			,em.Region
			,em.IDClasificacionCorporativa
			,em.ClasificacionCorporativa
			,em.IDRegPatronal
			,em.RegPatronal
			,em.IDTipoNomina
			,em.TipoNomina
			,em.SalarioDiario
			,em.SalarioDiarioReal
			,em.SalarioIntegrado
			,em.SalarioVariable
			,em.IDTipoPrestacion
			,em.IDRazonSocial
			,em.RazonSocial
			,em.IDAfore
			,em.Afore
			,em.Vigente
			,em.RowNumber
			,em.ClaveNombreCompleto
			,em.PermiteChecar
			,em.RequiereChecar
			,em.PagarTiempoExtra
			,em.PagarPrimaDominical
			,em.PagarDescansoLaborado
			,em.PagarFestivoLaborado
			,em.IDDocumento
			,em.Documento
			,em.IDTipoContrato
			,em.TipoContrato
			,em.FechaIniContrato
			,em.FechaFinContrato
			,em.TiposPrestacion
			,em.tipoTrabajadorEmpleado
			,(Select count(*) 
				from Intranet.tblSolicitudesEmpleado with(nolock)
				where IDEmpleado = em.IDEmpleado and IDEstatusSolicitud = 1 -- PENDIENTES
			) as SolicitudesPendientes	    
		from [RH].[tblEmpleadosMaster] em with (nolock)
			--join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where em.Vigente = 1 
			and (datepart(month,em.FechaNacimiento) = datepart(month,getdate()))
			and (datepart(day,em.FechaNacimiento) = datepart(day,getdate()))
			and (@query = '""' or CONTAINS(em.*, @query)) 
    end;

    if (@tipo = 3)
    begin
		print 'Cumpleaños en un fecha Específica'

		insert @ResponseEmpleados
		select 
			em.IDEmpleado
			,em.ClaveEmpleado
			,em.RFC
			,em.CURP
			,em.IMSS
			,em.Nombre
			,em.SegundoNombre
			,em.Paterno
			,em.Materno
			,em.NOMBRECOMPLETO
			,em.IDLocalidadNacimiento
			,em.LocalidadNacimiento
			,em.IDMunicipioNacimiento
			,em.MunicipioNacimiento
			,em.IDEstadoNacimiento
			,em.EstadoNacimiento
			,em.IDPaisNacimiento
			,em.PaisNacimiento
			,em.FechaNacimiento
			,em.IDEstadoCiviL
			,em.EstadoCivil
			,em.Sexo
			,em.IDEscolaridad
			,em.Escolaridad
			,em.DescripcionEscolaridad
			,em.IDInstitucion
			,em.Institucion
			,em.IDProbatorio
			,em.Probatorio
			,em.FechaPrimerIngreso
			,em.FechaIngreso
			,em.FechaAntiguedad
			,em.Sindicalizado
			,em.IDJornadaLaboral
			,em.JornadaLaboral
			,em.UMF
			,em.CuentaContable
			,em.IDTipoRegimen
			,em.TipoRegimen
			,em.IDPreferencia
			,em.IDDepartamento
			,em.Departamento
			,em.IDSucursal
			,em.Sucursal
			,em.IDPuesto
			,em.Puesto
			,em.IDCliente
			,em.Cliente
			,em.IDEmpresa
			,em.Empresa
			,em.IDCentroCosto
			,em.CentroCosto
			,em.IDArea
			,em.Area
			,em.IDDivision
			,em.Division
			,em.IDRegion
			,em.Region
			,em.IDClasificacionCorporativa
			,em.ClasificacionCorporativa
			,em.IDRegPatronal
			,em.RegPatronal
			,em.IDTipoNomina
			,em.TipoNomina
			,em.SalarioDiario
			,em.SalarioDiarioReal
			,em.SalarioIntegrado
			,em.SalarioVariable
			,em.IDTipoPrestacion
			,em.IDRazonSocial
			,em.RazonSocial
			,em.IDAfore
			,em.Afore
			,em.Vigente
			,em.RowNumber
			,em.ClaveNombreCompleto
			,em.PermiteChecar
			,em.RequiereChecar
			,em.PagarTiempoExtra
			,em.PagarPrimaDominical
			,em.PagarDescansoLaborado
			,em.PagarFestivoLaborado
			,em.IDDocumento
			,em.Documento
			,em.IDTipoContrato
			,em.TipoContrato
			,em.FechaIniContrato
			,em.FechaFinContrato
			,em.TiposPrestacion
			,em.tipoTrabajadorEmpleado
			,(Select count(*) 
				from Intranet.tblSolicitudesEmpleado with(nolock)
				where IDEmpleado = em.IDEmpleado and IDEstatusSolicitud = 1 -- PENDIENTES
			) as SolicitudesPendientes	     
		from [RH].[tblEmpleadosMaster] em with (nolock)
			--join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where em.Vigente = 1 
			and (datepart(month,em.FechaNacimiento) = datepart(month,@Fecha))
			and (datepart(day,em.FechaNacimiento) = datepart(day,@Fecha))
			and (@query = '""' or CONTAINS(em.*, @query)) 
    end;

	if (@tipo = 4)
    begin
		print 'Cumpleaños proximos 7 dias'

		insert @ResponseEmpleados
		select 
			em.IDEmpleado
			,em.ClaveEmpleado
			,em.RFC
			,em.CURP
			,em.IMSS
			,em.Nombre
			,em.SegundoNombre
			,em.Paterno
			,em.Materno
			,em.NOMBRECOMPLETO
			,em.IDLocalidadNacimiento
			,em.LocalidadNacimiento
			,em.IDMunicipioNacimiento
			,em.MunicipioNacimiento
			,em.IDEstadoNacimiento
			,em.EstadoNacimiento
			,em.IDPaisNacimiento
			,em.PaisNacimiento
			,em.FechaNacimiento
			,em.IDEstadoCiviL
			,em.EstadoCivil
			,em.Sexo
			,em.IDEscolaridad
			,em.Escolaridad
			,em.DescripcionEscolaridad
			,em.IDInstitucion
			,em.Institucion
			,em.IDProbatorio
			,em.Probatorio
			,em.FechaPrimerIngreso
			,em.FechaIngreso
			,em.FechaAntiguedad
			,em.Sindicalizado
			,em.IDJornadaLaboral
			,em.JornadaLaboral
			,em.UMF
			,em.CuentaContable
			,em.IDTipoRegimen
			,em.TipoRegimen
			,em.IDPreferencia
			,em.IDDepartamento
			,em.Departamento
			,em.IDSucursal
			,em.Sucursal
			,em.IDPuesto
			,em.Puesto
			,em.IDCliente
			,em.Cliente
			,em.IDEmpresa
			,em.Empresa
			,em.IDCentroCosto
			,em.CentroCosto
			,em.IDArea
			,em.Area
			,em.IDDivision
			,em.Division
			,em.IDRegion
			,em.Region
			,em.IDClasificacionCorporativa
			,em.ClasificacionCorporativa
			,em.IDRegPatronal
			,em.RegPatronal
			,em.IDTipoNomina
			,em.TipoNomina
			,em.SalarioDiario
			,em.SalarioDiarioReal
			,em.SalarioIntegrado
			,em.SalarioVariable
			,em.IDTipoPrestacion
			,em.IDRazonSocial
			,em.RazonSocial
			,em.IDAfore
			,em.Afore
			,em.Vigente
			,em.RowNumber
			,em.ClaveNombreCompleto
			,em.PermiteChecar
			,em.RequiereChecar
			,em.PagarTiempoExtra
			,em.PagarPrimaDominical
			,em.PagarDescansoLaborado
			,em.PagarFestivoLaborado
			,em.IDDocumento
			,em.Documento
			,em.IDTipoContrato
			,em.TipoContrato
			,em.FechaIniContrato
			,em.FechaFinContrato
			,em.TiposPrestacion
			,em.tipoTrabajadorEmpleado
			,(Select count(*) 
				from Intranet.tblSolicitudesEmpleado with(nolock)
				where IDEmpleado = em.IDEmpleado and IDEstatusSolicitud = 1 -- PENDIENTES
			) as SolicitudesPendientes	    
		from [RH].[tblEmpleadosMaster] em with (nolock)
			--join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		WHERE em.Vigente = 1 
			and ((1 = (FLOOR(DATEDIFF(dd,em.FechaNacimiento,GETDATE()+5) / 365.25))
				  -
				  (FLOOR(DATEDIFF(dd,em.FechaNacimiento,GETDATE()) / 365.25))) OR
				  (datepart(month,em.FechaNacimiento) = datepart(month,getdate()))
				  and 
				  (datepart(day,em.FechaNacimiento) = datepart(day,getdate()))
				)
			and (@query = '""' or CONTAINS(em.*, @query)) 
		order by MONTH(em.FechaNacimiento) asc,DAY(em.FechaNacimiento) asc
    end;

	if (@tipo = 5)
    begin	   
		insert @ResponseEmpleados
		select 
			em.IDEmpleado
			,em.ClaveEmpleado
			,em.RFC
			,em.CURP
			,em.IMSS
			,em.Nombre
			,em.SegundoNombre
			,em.Paterno
			,em.Materno
			,em.NOMBRECOMPLETO
			,em.IDLocalidadNacimiento
			,em.LocalidadNacimiento
			,em.IDMunicipioNacimiento
			,em.MunicipioNacimiento
			,em.IDEstadoNacimiento
			,em.EstadoNacimiento
			,em.IDPaisNacimiento
			,em.PaisNacimiento
			,em.FechaNacimiento
			,em.IDEstadoCiviL
			,em.EstadoCivil
			,em.Sexo
			,em.IDEscolaridad
			,em.Escolaridad
			,em.DescripcionEscolaridad
			,em.IDInstitucion
			,em.Institucion
			,em.IDProbatorio
			,em.Probatorio
			,em.FechaPrimerIngreso
			,em.FechaIngreso
			,em.FechaAntiguedad
			,em.Sindicalizado
			,em.IDJornadaLaboral
			,em.JornadaLaboral
			,em.UMF
			,em.CuentaContable
			,em.IDTipoRegimen
			,em.TipoRegimen
			,em.IDPreferencia
			,em.IDDepartamento
			,em.Departamento
			,em.IDSucursal
			,em.Sucursal
			,em.IDPuesto
			,em.Puesto
			,em.IDCliente
			,em.Cliente
			,em.IDEmpresa
			,em.Empresa
			,em.IDCentroCosto
			,em.CentroCosto
			,em.IDArea
			,em.Area
			,em.IDDivision
			,em.Division
			,em.IDRegion
			,em.Region
			,em.IDClasificacionCorporativa
			,em.ClasificacionCorporativa
			,em.IDRegPatronal
			,em.RegPatronal
			,em.IDTipoNomina
			,em.TipoNomina
			,em.SalarioDiario
			,em.SalarioDiarioReal
			,em.SalarioIntegrado
			,em.SalarioVariable
			,em.IDTipoPrestacion
			,em.IDRazonSocial
			,em.RazonSocial
			,em.IDAfore
			,em.Afore
			,em.Vigente
			,em.RowNumber
			,em.ClaveNombreCompleto
			,em.PermiteChecar
			,em.RequiereChecar
			,em.PagarTiempoExtra
			,em.PagarPrimaDominical
			,em.PagarDescansoLaborado
			,em.PagarFestivoLaborado
			,em.IDDocumento
			,em.Documento
			,em.IDTipoContrato
			,em.TipoContrato
			,em.FechaIniContrato
			,em.FechaFinContrato
			,em.TiposPrestacion
			,em.tipoTrabajadorEmpleado
			,(Select count(*) 
				from Intranet.tblSolicitudesEmpleado  with(nolock)
				where IDEmpleado = em.IDEmpleado and IDEstatusSolicitud = 1 -- PENDIENTES
			) as SolicitudesPendientes	    
		from [RH].[tblEmpleadosMaster] em with (nolock)
			join RH.tblJefesEmpleados dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDJefe = @IDEmpleado
		where em.Vigente = 1
			and em.IDEmpleado <> @IDEmpleado
			and (@query = '""' or CONTAINS(em.*, @query)) 
    end;

	if (@tipo = 6)
    begin
		insert @ResponseEmpleados
		select 
			em.IDEmpleado
			,em.ClaveEmpleado
			,em.RFC
			,em.CURP
			,em.IMSS
			,em.Nombre
			,em.SegundoNombre
			,em.Paterno
			,em.Materno
			,em.NOMBRECOMPLETO
			,em.IDLocalidadNacimiento
			,em.LocalidadNacimiento
			,em.IDMunicipioNacimiento
			,em.MunicipioNacimiento
			,em.IDEstadoNacimiento
			,em.EstadoNacimiento
			,em.IDPaisNacimiento
			,em.PaisNacimiento
			,em.FechaNacimiento
			,em.IDEstadoCiviL
			,em.EstadoCivil
			,em.Sexo
			,em.IDEscolaridad
			,em.Escolaridad
			,em.DescripcionEscolaridad
			,em.IDInstitucion
			,em.Institucion
			,em.IDProbatorio
			,em.Probatorio
			,em.FechaPrimerIngreso
			,em.FechaIngreso
			,em.FechaAntiguedad
			,em.Sindicalizado
			,em.IDJornadaLaboral
			,em.JornadaLaboral
			,em.UMF
			,em.CuentaContable
			,em.IDTipoRegimen
			,em.TipoRegimen
			,em.IDPreferencia
			,em.IDDepartamento
			,em.Departamento
			,em.IDSucursal
			,em.Sucursal
			,em.IDPuesto
			,em.Puesto
			,em.IDCliente
			,em.Cliente
			,em.IDEmpresa
			,em.Empresa
			,em.IDCentroCosto
			,em.CentroCosto
			,em.IDArea
			,em.Area
			,em.IDDivision
			,em.Division
			,em.IDRegion
			,em.Region
			,em.IDClasificacionCorporativa
			,em.ClasificacionCorporativa
			,em.IDRegPatronal
			,em.RegPatronal
			,em.IDTipoNomina
			,em.TipoNomina
			,em.SalarioDiario
			,em.SalarioDiarioReal
			,em.SalarioIntegrado
			,em.SalarioVariable
			,em.IDTipoPrestacion
			,em.IDRazonSocial
			,em.RazonSocial
			,em.IDAfore
			,em.Afore
			,em.Vigente
			,em.RowNumber
			,em.ClaveNombreCompleto
			,em.PermiteChecar
			,em.RequiereChecar
			,em.PagarTiempoExtra
			,em.PagarPrimaDominical
			,em.PagarDescansoLaborado
			,em.PagarFestivoLaborado
			,em.IDDocumento
			,em.Documento
			,em.IDTipoContrato
			,em.TipoContrato
			,em.FechaIniContrato
			,em.FechaFinContrato
			,em.TiposPrestacion
			,em.tipoTrabajadorEmpleado
			,(Select count(*) 
				from Intranet.tblSolicitudesEmpleado with(nolock)
				where IDEmpleado = em.IDEmpleado and IDEstatusSolicitud = 1 -- PENDIENTES
			) as SolicitudesPendientes	   
		from [RH].[tblEmpleadosMaster] em with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario	
		where em.Vigente = 1
			and em.IDEmpleado <> @IDEmpleado
			and (@query = '""' or CONTAINS(em.*, @query)) 
    end;

	if(@tipo = 7)
	BEGIN
		print 'Cumpleaños hoy'
 
		insert @ResponseEmpleados
		select 
			em.IDEmpleado
			,em.ClaveEmpleado
			,em.RFC
			,em.CURP
			,em.IMSS
			,em.Nombre
			,em.SegundoNombre
			,em.Paterno
			,em.Materno
			,em.NOMBRECOMPLETO
			,em.IDLocalidadNacimiento
			,em.LocalidadNacimiento
			,em.IDMunicipioNacimiento
			,em.MunicipioNacimiento
			,em.IDEstadoNacimiento
			,em.EstadoNacimiento
			,em.IDPaisNacimiento
			,em.PaisNacimiento
			,em.FechaNacimiento
			,em.IDEstadoCiviL
			,em.EstadoCivil
			,em.Sexo
			,em.IDEscolaridad
			,em.Escolaridad
			,em.DescripcionEscolaridad
			,em.IDInstitucion
			,em.Institucion
			,em.IDProbatorio
			,em.Probatorio
			,em.FechaPrimerIngreso
			,em.FechaIngreso
			,em.FechaAntiguedad
			,em.Sindicalizado
			,em.IDJornadaLaboral
			,em.JornadaLaboral
			,em.UMF
			,em.CuentaContable
			,em.IDTipoRegimen
			,em.TipoRegimen
			,em.IDPreferencia
			,em.IDDepartamento
			,em.Departamento
			,em.IDSucursal
			,em.Sucursal
			,em.IDPuesto
			,em.Puesto
			,em.IDCliente
			,em.Cliente
			,em.IDEmpresa
			,em.Empresa
			,em.IDCentroCosto
			,em.CentroCosto
			,em.IDArea
			,em.Area
			,em.IDDivision
			,em.Division
			,em.IDRegion
			,em.Region
			,em.IDClasificacionCorporativa
			,em.ClasificacionCorporativa
			,em.IDRegPatronal
			,em.RegPatronal
			,em.IDTipoNomina
			,em.TipoNomina
			,em.SalarioDiario
			,em.SalarioDiarioReal
			,em.SalarioIntegrado
			,em.SalarioVariable
			,em.IDTipoPrestacion
			,em.IDRazonSocial
			,em.RazonSocial
			,em.IDAfore
			,em.Afore
			,em.Vigente
			,em.RowNumber
			,em.ClaveNombreCompleto
			,em.PermiteChecar
			,em.RequiereChecar
			,em.PagarTiempoExtra
			,em.PagarPrimaDominical
			,em.PagarDescansoLaborado
			,em.PagarFestivoLaborado
			,em.IDDocumento
			,em.Documento
			,em.IDTipoContrato
			,em.TipoContrato
			,em.FechaIniContrato
			,em.FechaFinContrato
			,em.TiposPrestacion
			,em.tipoTrabajadorEmpleado
			,(Select count(*) 
				from Intranet.tblSolicitudesEmpleado with(nolock)
				where IDEmpleado = em.IDEmpleado and IDEstatusSolicitud = 1 -- PENDIENTES
			) as SolicitudesPendientes	    
		from [RH].[tblEmpleadosMaster] em with (nolock)
			--join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where em.Vigente = 1 
			and (datepart(month,em.FechaNacimiento) = datepart(month,getdate()))
			and (datepart(day,em.FechaNacimiento) = datepart(day,getdate()))
			and (@query = '""' or CONTAINS(em.*, @query)) 
			and (	
					(@Valor = 'Cliente' and em.IDCliente = @IDCliente)
					OR 
					(isnull(@Valor,'General') = 'General')
			)
	END

	if (@tipo = 8)
    begin
		print 'Cumpleaños proximos 7 dias'

		insert @ResponseEmpleados
		select 
			em.IDEmpleado
			,em.ClaveEmpleado
			,em.RFC
			,em.CURP
			,em.IMSS
			,em.Nombre
			,em.SegundoNombre
			,em.Paterno
			,em.Materno
			,em.NOMBRECOMPLETO
			,em.IDLocalidadNacimiento
			,em.LocalidadNacimiento
			,em.IDMunicipioNacimiento
			,em.MunicipioNacimiento
			,em.IDEstadoNacimiento
			,em.EstadoNacimiento
			,em.IDPaisNacimiento
			,em.PaisNacimiento
			,em.FechaNacimiento
			,em.IDEstadoCiviL
			,em.EstadoCivil
			,em.Sexo
			,em.IDEscolaridad
			,em.Escolaridad
			,em.DescripcionEscolaridad
			,em.IDInstitucion
			,em.Institucion
			,em.IDProbatorio
			,em.Probatorio
			,em.FechaPrimerIngreso
			,em.FechaIngreso
			,em.FechaAntiguedad
			,em.Sindicalizado
			,em.IDJornadaLaboral
			,em.JornadaLaboral
			,em.UMF
			,em.CuentaContable
			,em.IDTipoRegimen
			,em.TipoRegimen
			,em.IDPreferencia
			,em.IDDepartamento
			,em.Departamento
			,em.IDSucursal
			,em.Sucursal
			,em.IDPuesto
			,em.Puesto
			,em.IDCliente
			,em.Cliente
			,em.IDEmpresa
			,em.Empresa
			,em.IDCentroCosto
			,em.CentroCosto
			,em.IDArea
			,em.Area
			,em.IDDivision
			,em.Division
			,em.IDRegion
			,em.Region
			,em.IDClasificacionCorporativa
			,em.ClasificacionCorporativa
			,em.IDRegPatronal
			,em.RegPatronal
			,em.IDTipoNomina
			,em.TipoNomina
			,em.SalarioDiario
			,em.SalarioDiarioReal
			,em.SalarioIntegrado
			,em.SalarioVariable
			,em.IDTipoPrestacion
			,em.IDRazonSocial
			,em.RazonSocial
			,em.IDAfore
			,em.Afore
			,em.Vigente
			,em.RowNumber
			,em.ClaveNombreCompleto
			,em.PermiteChecar
			,em.RequiereChecar
			,em.PagarTiempoExtra
			,em.PagarPrimaDominical
			,em.PagarDescansoLaborado
			,em.PagarFestivoLaborado
			,em.IDDocumento
			,em.Documento
			,em.IDTipoContrato
			,em.TipoContrato
			,em.FechaIniContrato
			,em.FechaFinContrato
			,em.TiposPrestacion
			,em.tipoTrabajadorEmpleado
			,(Select count(*) 
				from Intranet.tblSolicitudesEmpleado with(nolock)
				where IDEmpleado = em.IDEmpleado and IDEstatusSolicitud = 1 -- PENDIENTES
			) as SolicitudesPendientes	    
		from [RH].[tblEmpleadosMaster] em with (nolock)
			--join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		WHERE em.Vigente = 1 
			and ((1 = (FLOOR(DATEDIFF(dd,em.FechaNacimiento,GETDATE()+5) / 365.25))
				  -
				  (FLOOR(DATEDIFF(dd,em.FechaNacimiento,GETDATE()) / 365.25))) OR
				  (datepart(month,em.FechaNacimiento) = datepart(month,getdate()))
				  and 
				  (datepart(day,em.FechaNacimiento) = datepart(day,getdate()))
				)
			and (@query = '""' or CONTAINS(em.*, @query)) 
			and (	
					(@Valor = 'Cliente' and em.IDCliente = @IDCliente)
					OR 
					(isnull(@Valor,'General') = 'General')
			)
		order by MONTH(em.FechaNacimiento) asc,DAY(em.FechaNacimiento) asc
    end;

	
	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @ResponseEmpleados

	select @TotalRegistros = cast(COUNT([IDEmpleado]) as decimal(18,2)) from @ResponseEmpleados		


	select *
	,Utilerias.GetInfoUsuarioEmpleadoFotoAvatar(IDEmpleado,0) as UsuarioEmpleadoFotoAvatar
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,@TotalRegistros as TotalRegistros
	from @ResponseEmpleados
	order by 
		case when @orderByColumn = 'ClaveEmpleado'		and @orderDirection = 'asc'		then ClaveEmpleado end,			
		case when @orderByColumn = 'ClaveEmpleado'		and @orderDirection = 'desc'	then ClaveEmpleado end desc,			
		case when @orderByColumn = 'NombreCompleto'		and @orderDirection = 'asc'		then NombreCompleto end,			
		case when @orderByColumn = 'NombreCompleto'		and @orderDirection = 'desc'	then NombreCompleto end desc,			
		case when @orderByColumn = 'Departamento'		and @orderDirection = 'asc'		then Departamento end,		
		case when @orderByColumn = 'Departamento'		and @orderDirection = 'desc'	then Departamento end desc,		
		case when @orderByColumn = 'Sucursal'			and @orderDirection = 'asc'		then Sucursal end,				
		case when @orderByColumn = 'Sucursal'			and @orderDirection = 'desc'	then Sucursal end desc,				
		case when @orderByColumn = 'Puesto'				and @orderDirection = 'asc'		then Puesto end,					
		case when @orderByColumn = 'Puesto'				and @orderDirection = 'desc'	then Puesto end desc,					
		case when @orderByColumn = 'Division'			and @orderDirection = 'asc'		then Division end,			
		case when @orderByColumn = 'Division'			and @orderDirection = 'desc'	then Division end desc,			
		case when @orderByColumn = 'CentroCosto'		and @orderDirection = 'asc'		then CentroCosto end,			
		case when @orderByColumn = 'CentroCosto'		and @orderDirection = 'desc'	then CentroCosto end desc,			
		case when @orderByColumn = 'ClasificacionCorporativa'  and @orderDirection = 'asc'	then ClasificacionCorporativa end,
		case when @orderByColumn = 'ClasificacionCorporativa'  and @orderDirection = 'desc'	then ClasificacionCorporativa end desc,
		ClaveEmpleado asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
