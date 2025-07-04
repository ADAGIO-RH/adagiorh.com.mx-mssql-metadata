USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: 
** Autor			: Jose VARGAS
** Email			: jvargas@adagiorh.com
** FechaCreacion	: 
** Paremetros		:              	

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE proc [RH].[spFilterEmpleadosWithoutValidateFiltros](  
	@IDUsuario	int
    ,@filter	varchar(1000)   
	,@vigente   bit = null	
    
)as   
	
   declare @IDEmpleado int

	select @IDEmpleado = isnull(IDEmpleado,0) from Seguridad.tblUsuarios where IDUsuario = @IDUsuario

	select  e.IDEmpleado
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
			,e.SalarioDiario
			,e.SalarioDiarioReal
			,e.SalarioIntegrado
			,e.SalarioVariable
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
			,e.TipoContrato
			,e.FechaIniContrato
			,e.FechaFinContrato
			,e.TiposPrestacion
			,e.tipoTrabajadorEmpleado		   
	from [RH].[tblEmpleadosMaster] e with (nolock)						
	where [ClaveNombreCompleto] like '%'+@filter+'%'  
		and (e.Vigente = case when @vigente is not null then @vigente else e.Vigente end)		
	order by e.ClaveEmpleado asc
GO
