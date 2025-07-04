USE [p_adagioRHIndustrialMefi]
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
	@tipo = 1		: Vigentes
			0		: No Vigentes
			Null	: Ambos

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			ANEUDY ABREU		Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
										Seguridad.tblDetalleFiltrosEmpleadosUsuarios
2020-10-13			Joseph Roman		Se agrega campo de Descripcion de TiposPrestacion 
										Para que cargue la variable en el trabajador en la busqueda rapida.
2022-09-21			Alejandro Paredes	Se agrego la columna iniciales
2023-12-26			ANEUDY ABREU		Se agregó la función ISNULL a las columnas de Salarios
2024-02-21			Justin Davila		Se agrego la columna IDGenero y su respectivo join a
										RH.tblCatGeneros
2023-10-11          Andrea Zainos       Se cambia la descripcion por la traduccion del Tipos de Prestaciones
***************************************************************************************************/
CREATE proc [RH].[spFilterEmpleados](  
	@IDUsuario	int = 0  
	,@filter	varchar(1000)   
	,@tipo		int = null
	,@intranet	bit = 0
)as   
	declare @IDEmpleado int
    ,@IDIdioma varchar(max)
	;
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	

	select @IDEmpleado = isnull(IDEmpleado,0) from Seguridad.tblUsuarios where IDUsuario = @IDUsuario

	select  
    e.IDEmpleado
			,e.ClaveEmpleado
			,e.RFC
			,e.CURP
			,e.IMSS
			,e.Nombre
			,e.SegundoNombre
			,e.Paterno
			,e.Materno
			,e.NOMBRECOMPLETO
			,e.IDLocalidadNacimiento
			,e.LocalidadNacimiento
			,e.IDMunicipioNacimiento
			,e.MunicipioNacimiento
			,e.IDEstadoNacimiento
			,e.EstadoNacimiento
			,e.IDPaisNacimiento
			,e.PaisNacimiento
			,e.FechaNacimiento
			,e.IDEstadoCiviL
			,e.EstadoCivil
			,e.Sexo
			,cg.IDGenero
			,e.IDEscolaridad
			,e.Escolaridad
			,e.DescripcionEscolaridad
			,e.IDInstitucion
			,e.Institucion
			,e.IDProbatorio
			,e.Probatorio
			,e.FechaPrimerIngreso
			,e.FechaIngreso
			,e.FechaAntiguedad
			,e.Sindicalizado
			,e.IDJornadaLaboral
			,e.JornadaLaboral
			,e.UMF
			,e.CuentaContable
			,e.IDTipoRegimen
			,e.TipoRegimen
			,e.IDPreferencia
			,e.IDDepartamento
			,e.Departamento
			,e.IDSucursal
			,e.Sucursal
			,e.IDPuesto
			,e.Puesto
			,e.IDCliente
			,e.Cliente
			,e.IDEmpresa
			,e.Empresa
			,e.IDCentroCosto
			,e.CentroCosto
			,e.IDArea
			,e.Area
			,e.IDDivision
			,e.Division
			,e.IDRegion
			,e.Region
			,e.IDClasificacionCorporativa
			,e.ClasificacionCorporativa
			,e.IDRegPatronal
			,e.RegPatronal
			,e.IDTipoNomina
			,e.TipoNomina
			,isnull(e.SalarioDiario		,0.00) as SalarioDiario		
			,isnull(e.SalarioDiarioReal	,0.00) as SalarioDiarioReal	
			,isnull(e.SalarioIntegrado	,0.00) as SalarioIntegrado	
			,isnull(e.SalarioVariable	,0.00) as SalarioVariable	
			,e.IDTipoPrestacion
			,e.IDRazonSocial
			,e.RazonSocial
			,e.IDAfore
			,e.Afore
			,e.Vigente
			,e.RowNumber
			,e.ClaveNombreCompleto
			,e.PermiteChecar
			,e.RequiereChecar
			,e.PagarTiempoExtra
			,e.PagarPrimaDominical
			,e.PagarDescansoLaborado
			,e.PagarFestivoLaborado
			,e.IDDocumento
			,e.Documento
			,isnull(tte.IDTipoContrato,0) as IDTipoContrato
			,e.TipoContrato
			,e.FechaIniContrato
			,e.FechaFinContrato			
			,e.tipoTrabajadorEmpleado
			,SUBSTRING (e.Nombre, 1, 1) + SUBSTRING (e.Paterno, 1, 1) as Iniciales
			,e.IDTipoPrestacion
		   ,JSON_VALUE(TP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TiposPrestacion	  
		   ,isnull(tte.IDTipoTrabajador,0)as IDTipoTrabajador
		   ,isnull(tte.IDTipoSalario,0)as IDTipoSalario
		   ,isnull(tte.IDTipoPension,0)as IDTipoPension
		   ,Empleados.DomicilioFiscal
		   ,isnull(Empleados.IDRegimenFiscal,0) as IDRegimenFiscal
		   ,Empleados.CodigoLector
		   ,isnull(TJ.IDTipoJornada,0)as IDTipoJornada
           ,isnull(Empleados.RequiereTransporte,0) as [RequiereTransporte]
		   ,isnull(u.IDUsuario, 0) as IDUsuario      
           ,[Utilerias].[fnGetUrlFotoUsuario](u.Cuenta) as UrlFoto
		from [RH].[tblEmpleadosMaster] e with (nolock)
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado 
			and dfe.IDUsuario = @IDUsuario
		inner join RH.tblEmpleados Empleados with(nolock) on e.IDEmpleado = Empleados.IDEmpleado
		inner join Seguridad.tblUsuarios u on u.IDEmpleado = e.IDEmpleado
		inner join RH.tblCatGeneros cg on cg.IDGenero = Empleados.Sexo
		left join RH.tblCatTiposPrestaciones TP with (nolock)  on e.IDTipoPrestacion = TP.IDTipoPrestacion
		left join RH.tblTipoTrabajadorEmpleado tte with (nolock) on e.IDEmpleado = tte.IDEmpleado
		left join IMSS.tblCatTipoJornada TJ on TJ.IDTipoJornada = Empleados.IDTipoJornada		
	where [ClaveNombreCompleto] like '%'+@filter+'%'  
		and (e.Vigente = case when @tipo is not null then @tipo else e.Vigente end)
		and (e.IDEmpleado <> case when @intranet = 1 then @IDEmpleado else 0  end)
	order by e.ClaveEmpleado asc
GO
