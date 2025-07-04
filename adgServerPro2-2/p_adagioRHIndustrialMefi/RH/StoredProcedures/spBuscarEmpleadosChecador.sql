USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca empleados checador
** Autor			: Jose Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE proc [RH].[spBuscarEmpleadosChecador](  
	@ClaveEmpleado varchar(1000)
	,@GenerarClave bit = 0
	,@IDLector int = 0
	,@IDUsuario int   
)as  
  
	declare
		@IDClienteLector int
	;

	if (isnull(@GenerarClave, 0) = 1) 
	begin
		IF not (ISNUMERIC(@ClaveEmpleado) = 1 AND @ClaveEmpleado NOT LIKE '%[^0-9]%')
		begin
			raiserror('Escriba su clave de empleado sin prefijo.', 16, 1)
			return
		end
		
		select @IDClienteLector = IDCliente
		from Asistencia.tblLectores with (nolock)
		where IDLector = @IDLector
		
		declare @TempClaveEmpleado table (
			ClaveEmpleado varchar(20)
		)

		insert @TempClaveEmpleado
		exec [RH].[spGenerarClaveEmpleado]
			 @IDCliente = @IDClienteLector,  
			 @MAXClaveID  = @ClaveEmpleado,  
			 @IDUsuario = @IDUsuario

		select top 1 @ClaveEmpleado = ClaveEmpleado
		from @TempClaveEmpleado
	end
  
    select top 1
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
		,isnull(e.IDLocalidadNacimiento, 0) as IDLocalidadNacimiento
		,e.LocalidadNacimiento
		,isnull(e.IDMunicipioNacimiento, 0) as IDMunicipioNacimiento
		,e.MunicipioNacimiento
		,isnull(e.IDEstadoNacimiento, 0) as IDEstadoNacimiento
		,e.EstadoNacimiento
		,isnull(e.IDPaisNacimiento, 0) as IDPaisNacimiento
		,e.PaisNacimiento
		,isnull(e.FechaNacimiento, '1900-01-01') as FechaNacimiento
		,isnull(e.IDEstadoCiviL, 0) as IDEstadoCiviL
		,e.EstadoCivil
		,e.Sexo
		,isnull(e.IDEscolaridad, 0) as IDEscolaridad
		,e.Escolaridad
		,e.DescripcionEscolaridad
		,isnull(e.IDInstitucion, 0) as IDInstitucion
		,e.Institucion
		,isnull(e.IDProbatorio, 0) as IDProbatorio
		,e.Probatorio
		,isnull(e.FechaPrimerIngreso, '1900-01-01') as FechaPrimerIngreso
		,isnull(e.FechaIngreso		, '1900-01-01') as FechaIngreso
		,isnull(e.FechaAntiguedad	, '1900-01-01') as FechaAntiguedad
		,isnull(e.Sindicalizado		, 0) as Sindicalizado
		,isnull(e.IDJornadaLaboral	, 0) as IDJornadaLaboral
		,e.JornadaLaboral
		,e.UMF
		,e.CuentaContable
		,isnull(e.IDTipoRegimen, 0) as IDTipoRegimen
		,e.TipoRegimen
		,isnull(e.IDPreferencia, 0) as IDPreferencia
		,isnull(e.IDDepartamento, 0) as IDDepartamento
		,e.Departamento
		,isnull(e.IDSucursal, 0) as IDSucursal
		,e.Sucursal
		,isnull(e.IDPuesto, 0) as IDPuesto
		,e.Puesto
		,isnull(e.IDCliente, 0) as IDCliente
		,e.Cliente
		,isnull(e.IDEmpresa, 0) as IDEmpresa
		,e.Empresa
		,isnull(e.IDCentroCosto, 0) as IDCentroCosto
		,e.CentroCosto
		,isnull(e.IDArea, 0) as IDArea
		,e.Area
		,isnull(e.IDDivision, 0) as IDDivision
		,e.Division
		,isnull(e.IDRegion, 0) as IDRegion
		,e.Region
		,isnull(e.IDClasificacionCorporativa, 0) as IDClasificacionCorporativa
		,e.ClasificacionCorporativa
		,isnull(e.IDRegPatronal, 0) as IDRegPatronal
		,e.RegPatronal
		,isnull(e.IDTipoNomina, 0) as IDTipoNomina
		,e.TipoNomina
		,isnull(e.SalarioDiario		, 0) as SalarioDiario
		,isnull(e.SalarioDiarioReal	, 0) as SalarioDiarioReal
		,isnull(e.SalarioIntegrado	, 0) as SalarioIntegrado
		,isnull(e.SalarioVariable	, 0) as SalarioVariable
		,isnull(e.IDTipoPrestacion	, 0) as IDTipoPrestacion
		,isnull(e.IDRazonSocial		, 0) as IDRazonSocial
		,e.RazonSocial
		,isnull(e.IDAfore, 0) as IDAfore
		,e.Afore
		,isnull(e.Vigente, 0) as Vigente
		,isnull(e.RowNumber, 0) as RowNumber
		,e.ClaveNombreCompleto
		,isnull(e.PermiteChecar			, 0) as PermiteChecar
		,isnull(e.RequiereChecar		, 0) as RequiereChecar
		,isnull(e.PagarTiempoExtra		, 0) as PagarTiempoExtra
		,isnull(e.PagarPrimaDominical	, 0) as PagarPrimaDominical
		,isnull(e.PagarDescansoLaborado	, 0) as PagarDescansoLaborado
		,isnull(e.PagarFestivoLaborado	, 0) as PagarFestivoLaborado
		,isnull(e.IDDocumento			, 0) as IDDocumento
		,e.Documento
		,isnull(e.IDTipoContrato, 0) as IDTipoContrato
		,e.TipoContrato
		,isnull(e.FechaIniContrato, '1900-01-01') as FechaIniContrato
		,isnull(e.FechaFinContrato, '1900-01-01') as FechaFinContrato
		,e.TiposPrestacion
		,e.tipoTrabajadorEmpleado
    from [RH].[tblEmpleadosMaster] e  
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
    where e.ClaveEmpleado = @ClaveEmpleado
GO
