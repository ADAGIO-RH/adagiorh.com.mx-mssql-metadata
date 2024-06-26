USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los recibos de nómina pendientes de timbrado
** Autor			: Jose Román
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
--select * from Nomina.tblCatPeriodos
CREATE PROCEDURE [Facturacion].[spBuscarPendientesTimbrado] --5587, 120,0,1        
(        
    @Folio int      
   ,@IDPeriodo int      
   ,@Timbrado bit      
   ,@IDUsuario int
)        
AS        
BEGIN        
        
	DECLARE         
		 @IDTipoNomina int         
		 ,@Ejercicio int         
		 ,@ClavePeriodo varchar(20)         
		 ,@DescripcionPeriodo varchar(250)         
		 ,@FechaInicioPago date         
		 ,@FechaFinPago date         
		 ,@FechaInicioIncidencia date         
		 ,@FechaFinIncidencia date         
		 ,@Dias int         
		 ,@AnioInicio bit         
		 ,@AnioFin bit         
		 ,@MesInicio bit         
		 ,@MesFin bit         
		 ,@IDMes int         
		 ,@BimestreInicio bit         
		 ,@BimestreFin bit         
		 ,@General bit         
		 ,@Finiquito bit         
		 ,@Especial bit         
		 ,@Cerrado bit 
		 ,@dtEmpleados RH.dtEmpleados
        ;


	select top 1         
		@IDPeriodo = p.IDPeriodo ,@IDTipoNomina= p.IDTipoNomina,@Ejercicio = p.Ejercicio,@ClavePeriodo = p.ClavePeriodo,@DescripcionPeriodo =  p.Descripcion         
		,@FechaInicioPago = p.FechaInicioPago,@FechaFinPago = p.FechaFinPago,@FechaInicioIncidencia = p.FechaInicioIncidencia,@FechaFinIncidencia=  p.FechaFinIncidencia         
		,@Dias = p.Dias,@AnioInicio = p.AnioInicio,@AnioFin = p.AnioFin,@MesInicio = p.MesInicio,@MesFin = p.MesFin         
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin         
		,@General = p.General,@Finiquito = p.Finiquito,@Especial = p.Especial,@Cerrado = p.Cerrado         
	from Nomina.tblCatPeriodos p        
	Where p.IDPeriodo = @IDPeriodo     
	
	

	 
	select Historial.IDHistorialEmpleadoPeriodo        
		,isnull(Historial.IDPeriodo,0) as IDPeriodo        
		,Periodos.Ejercicio        
		,Periodos.ClavePeriodo        
		,Periodos.Descripcion        
		,cast(Periodos.FechaInicioPago as date)   FechaInicioPago      
		,cast(Periodos.FechaFinPago as date) FechaFinPago        
		,case when isnull(Periodos.Especial,0) = 0 then  Periodicidad.Codigo else '99' end as CodigoPeriodicidadPago        
		,case when isnull(Periodos.Especial,0) = 0 then  Periodicidad.Descripcion else 'Otra Periodicidad' end  as PeriodicidadPago        
		,CEILING( isnull((Select CASE WHEN isnull(ImporteTotal1,0)> 0 then  ImporteTotal1 else Periodos.Dias END        
				   from Nomina.tblDetallePeriodo dp        
					inner join Nomina.tblCatConceptos c on DP.IDConcepto = c.IDConcepto        
				   where dp.IDEmpleado = Historial.IDEmpleado         
					and dp.IDPeriodo = Historial.IDPeriodo        
					and c.Codigo = '005'        
				   ),Periodos.Dias)) as DiasPagados        
		,CASE WHEN (Periodos.Especial = 1 )  Then (Select Top 1 Codigo FROM Sat.tblCatTiposNomina Where IDTipoNomina = 2)        
			  ELSE (Select Top 1 Codigo FROM Sat.tblCatTiposNomina Where IDTipoNomina = 1)        
			  END TipoNomina        
		,isnull(TipoNomina.IDTipoNomina,0) AS IDTipoNomina        
		,isnull(Historial.IDEmpleado,0) as IDEmpleado        
		,Empleado.ClaveEmpleado        
		,COALESCE(Empleado.Paterno,'')+' '+COALESCE(Empleado.Materno,'')+' '+COALESCE(Empleado.Nombre,'')+' '+COALESCE(Empleado.SegundoNombre,'') AS NOMBRECOMPLETO        
		,COALESCE(Empleado.Paterno,'')  as Paterno        
		,COALESCE(Empleado.Materno,'')  as Materno        
		,COALESCE(Empleado.Nombre,'')+' '+COALESCE(Empleado.SegundoNombre,'') as Nombres        
		,Empleado.FechaNacimiento        
		,Municipios.Codigo as CodigoMunicipioNacimiento        
		,Estados.NombreEstado as EstadoNacimiento        
		,Paises.Codigo as CodigoPaisNacimiento        
		,Empleado.Sexo as Sexo        
		,Empleado.RFC        
		,Empleado.CURP        
		,Empleado.IMSS        
		,CAST(Empleado.FechaPrimerIngreso as Date) FechaPrimerIngreso       
		,Cast(Empleado.FechaIngreso as date)  FechaIngreso        
		,Cast(CASE WHEN Empleado.FechaAntiguedad <= @FechaFinPago THEN Empleado.FechaAntiguedad else Empleado.FechaIngreso end as date)  FechaAntiguedad      
		--,COALESCE('P'+CAST(((DATEDIFF(DAY,Empleado.FechaAntiguedad,Periodos.FechaFinPago)+1)/7) AS Varchar)+'W','') as Antiguedad       
		,Facturacion.fnAntiguedadSAT(CASE WHEN Empleado.FechaAntiguedad <= @FechaFinPago THEN Empleado.FechaAntiguedad else Empleado.FechaIngreso end ,Periodos.FechaFinPago) as Antiguedad
		,Empleado.Sindicalizado        
		,ISNULL(MOV.SalarioDiario,0.00) as SalarioDiario         
		,ISNULL(MOV.SalarioIntegrado,0.00) as SalarioIntegrado         
		,isnull(Empleado.IDJornadaLaboral,0) as    IDJornadaLaboral     
		,COALESCE(Jornada.Codigo,'') CodigoJornada        
		,COALESCE(Jornada.Codigo,'')+' '+COALESCE(Jornada.Descripcion,'') as Jornada        
		--,ISNULL(Bancos.IDBanco,0) as IDBanco        
		--,COALESCE(Bancos.Codigo,'')+' '+COALESCE(Bancos.Descripcion,'') as Banco        
		--,COALESCE(Pago.Cuenta,'') as Cuenta        
		--,COALESCE(Pago.Sucursal,'') as SucursalBancaria        
		--,ISNULL(Layout.IDLayoutPago,0) as IDLayoutPago        
		--,COALESCE(Layout.Descripcion,'') as LayoutPago         
        
		,ISNULL(Historial.IDCentroCosto,0) as IDCentroCosto        
		,COALESCE(CentroCosto.Codigo,'')+' '+COALESCE(CentroCosto.Descripcion,'') as CentroCosto        
		,ISNULL(Historial.IDDepartamento,0) as IDDepartamento        
		,COALESCE(Departamentos.Codigo,'')+' '+COALESCE(Departamentos.Descripcion,'') as Departamento        
		,ISNULL(Historial.IDSucursal,0) as IDSucursal        
		,COALESCE(Sucursales.Codigo,'')+' '+COALESCE(Sucursales.Descripcion,'') as Sucursal        
		,ISNULL(Historial.IDPuesto,0) as IDPuesto        
		,COALESCE(Puestos.Codigo,'')+' '+COALESCE(Puestos.Descripcion,'') as Puesto        
		,ISNULL(Historial.IDRegPatronal,0) as IDRegPatronal        
		,COALESCE(RegPatronal.RegistroPatronal,'') as RegistroPatronal        
		,COALESCE(RegPatronal.RazonSocial,'') as RazonSocial        
		--,COALESCE(Riesgos.Codigo,'') as Riesgo    
		,CASE WHEN ImssRiesgo.Codigo = 'I' THEN '1'
			  WHEN ImssRiesgo.Codigo = 'II' THEN '2'
			  WHEN ImssRiesgo.Codigo = 'III' THEN '3'
			  WHEN ImssRiesgo.Codigo = 'IV' THEN '4'
			  WHEN ImssRiesgo.Codigo = 'V' THEN '5'
			  WHEN isnull(ImssRiesgo.Codigo,'') = '' THEN '99'
			  END Riesgo
		,ISNULL(Historial.IDCliente,0) as IDCliente        
		,COALESCE(Clientes.NombreComercial,'') as Cliente        
		,ISNULL(Historial.IDEmpresa,0) as IDEmpresa        
		,COALESCE(Empresas.RFC,'') as RFCEmisor        
		,COALESCE(Empresas.NombreComercial,'') as Empresa        
		,ISNULL(Historial.IDRazonSocial,0) as IDBeneficiarioSubcontratacion        
		,COALESCE(RS.RFC,'') as RFCBeneficiarioSubcontratacion        
        
		,ISNULL(Empresas.IDCodigoPostal,0) as IDCodigoPostal        
		,COALESCE(CP.CodigoPostal,'') as CodigoPostal        
		,COALESCE(Estado.Codigo,'') as EntidadFederativa        
            
		,ISNULL(Empresas.IDRegimenFiscal,0) as IDRegimenFiscal        
		,COALESCE(RegimenesFiscales.Codigo,'') as CodigoRegimenFiscal        
		,COALESCE(RegimenesFiscales.Descripcion,'') as RegimenFiscal        
		,ISNULL(Empresas.IDOrigenRecurso,0) as IDOrigenRecurso        
		,COALESCE(OrigenesRecursos.Codigo,'') as CodigoOrigenRecurso        
		,COALESCE(OrigenesRecursos.Descripcion,'') as OrigenRecurso        
        ,COALESCE(isnull(TipoContrato.Codigo,'01'),'') as CodigoTipoContrato  ------------------------      
		,COALESCE(isnull(TipoContrato.Descripcion,'01'),'') as TipoContrato -------------------------        
  
        
		,ISNULL(Historial.IDArea,0) as IDArea        
		,COALESCE(Areas.Codigo,'')+' '+COALESCE(Areas.Descripcion,'') as Area        
		,ISNULL(Historial.IDDivision,0) as IDDivision        
		,COALESCE(Divisiones.Codigo,'')+' '+COALESCE(Divisiones.Descripcion,'') as Division        
		,ISNULL(Historial.IDClasificacionCorporativa,0) as IDClasificacionCorporativa        
		,COALESCE(clasificaciones.Codigo,'')+' '+COALESCE(clasificaciones.Descripcion,'') as ClasificacionCorporativa        
		,ISNULL(Historial.IDRegion,0) as IDRegion        
		,COALESCE(Regiones.Codigo,'')+' '+COALESCE(Regiones.Descripcion,'') as Region        
		,ISNULL(Timbrado.IDTimbrado,0) as IDTimbrado        
		,ISNULL(Timbrado.IDTipoRegimen,0) as IDTipoRegimen        
		,COALESCE(TiposRegimen.Codigo,'')as CodigoTipoRegimen        
		,COALESCE(TiposRegimen.Codigo,'')+' '+COALESCE(TiposRegimen.Descripcion,'') as TipoRegimen        
		,COALESCE(Timbrado.UUID,'') as UUID         
		,COALESCE(Timbrado.ACUSE,'') as ACUSE         
		,ISNULL(Timbrado.IDEstatusTimbrado,1) as IDEstatusTimbrado        
		,COALESCE(EstatusTimbrado.Descripcion,'NUEVO') as EstatusTimbrado        
		,COALESCE(Timbrado.Fecha,'') as Fecha        
		,ISNULL(Timbrado.IDUsuario,0) as IDUsuario        
		,COALESCE(Usuarios.Cuenta,'') as Usuario        
		,COALESCE(Timbrado.CodigoError,'') as CodigoError        
		,COALESCE(Timbrado.Error,'') as Error  
		,Clientes.PathReciboNomina as PathRecibo
           
	From Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)    
		--join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = Historial.IDEmpleado and dfe.IDUsuario = @IDUsuario   
		Inner join Nomina.tblCatPeriodos Periodos  with (nolock)      
			on Historial.IDPeriodo = Periodos.IDPeriodo        
		Inner Join Nomina.tblCatTipoNomina TipoNomina  with (nolock)      
			on TipoNomina.IDTipoNomina = Periodos.IDTipoNomina        
		INNER JOIN Sat.tblCatPeriodicidadesPago Periodicidad with (nolock)       
			on Periodicidad.IDPeriodicidadPago = TipoNomina.IDPeriodicidadPago        
		--Inner join RH.tblEmpleados Empleado        
		--	on Historial.IDEmpleado = Empleado.IDEmpleado        
		Inner join RH.tblEmpleadosMaster Empleado  with (nolock)      
			on Historial.IDEmpleado = Empleado.IDEmpleado
		Left Join Sat.tblCatMunicipios Municipios  with (nolock)      
			on Empleado.IDMunicipioNacimiento = Municipios.IDMunicipio         
		Left Join Sat.tblCatEstados Estados   with (nolock)     
			on Empleado.IDEstadoNacimiento = Estados.IDEstado        
		Left Join Sat.tblCatPaises Paises  with (nolock)      
			on Empleado.IDPaisNacimiento = Paises.IDPais        
		Left Join Sat.tblCatTiposJornada jornada with (nolock)       
			on Empleado.IDJornadaLaboral = Jornada.IDTipoJornada        
		 --Left Join RH.tblPagoEmpleado Pago        
		 -- on Empleado.IDEmpleado = Pago.IDEmpleado        
        
		 --Left Join Nomina.tblLayoutPago Layout        
		 -- on Pago.IDLayoutPago = Layout.IDLayoutPago        
		 --Left Join Sat.tblCatBancos Bancos        
		 -- on Bancos.IDBanco = Pago.IDBanco        
        
		Left join RH.tblCatCentroCosto CentroCosto with (nolock)       
			on Historial.IDCentroCosto = CentroCosto.IDCentroCosto        
		Left Join RH.tblCatDepartamentos Departamentos with (nolock)       
			on Historial.IDDepartamento = Departamentos.IDDepartamento        
		Left Join RH.tblCatSucursales Sucursales  with (nolock)      
			on Historial.IDSucursal = Sucursales.IDSucursal        
		Left Join RH.tblCatPuestos Puestos    with (nolock)    
			on Historial.IDPuesto = Puestos.IDPuesto        
		Left Join RH.TblCatRegPatronal RegPatronal  with (nolock)      
			on Historial.IDRegPatronal = RegPatronal.IDRegPatronal        
		Left Join Sat.tblCatRiesgosPuesto Riesgos  with (nolock)      
			on Riesgos.IDRiesgoPuesto = RegPatronal.IDClaseRiesgo
		left join IMSS.tblCatClaseRiesgo ImssRiesgo with (nolock)
			on ImssRiesgo.IDClaseRiesgo = RegPatronal.IDClaseRiesgo
		Left Join RH.tblCatClientes Clientes    with (nolock)    
			on Historial.IDCliente = Clientes.IDCliente        
		Left Join RH.tblEmpresa Empresas    with (nolock)    
			on Historial.IDEmpresa = Empresas.IDEmpresa        
		Left Join Sat.tblCatCodigosPostales CP    with (nolock)    
			on CP.IDCodigoPostal = Empresas.IDCodigoPostal        
		Left Join Sat.tblCatEstados Estado  with (nolock)      
			on Empresas.IDEstado = Estado.IDEstado        
		Left Join Sat.tblCatRegimenesFiscales RegimenesFiscales   with (nolock)     
			on RegimenesFiscales.IDRegimenFiscal = Empresas.IDRegimenFiscal        
		Left Join Sat.tblCatOrigenesRecursos OrigenesRecursos with (nolock)       
			on OrigenesRecursos.IDOrigenRecurso = Empresas.IDOrigenRecurso  
		left join Sat.tblCatTiposContrato TipoContrato with (nolock)-------------------------
			on Empleado.IDTipoContrato = TipoContrato.IDTipoContrato----------------------------     
		Left Join RH.tblCatArea Areas   with (nolock)     
			on Historial.IDArea = Areas.IDArea        
		LEft JOIn RH.tblCatDivisiones Divisiones with (nolock)        
			on Historial.IDDivision = Divisiones.IDDivision        
		Left Join RH.tblCatClasificacionesCorporativas clasificaciones with (nolock)       
			on Historial.IDclasificacionCorporativa = Clasificaciones.IDClasificacionCorporativa        
		Left Join RH.tblCatRegiones Regiones  with (nolock)      
			on Historial.IDRegion = Regiones.IDRegion        
		Left Join RH.tblCatRazonesSociales RS with (nolock)       
			on Historial.IDRazonSocial = RS.IDRazonSocial        
		Left Join Facturacion.tblTimbrado Timbrado  with (nolock)      
			on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo and timbrado.Actual = 1        
		LEFT join Facturacion.tblCatEstatusTimbrado Estatustimbrado   with (nolock)     
			on Timbrado.IDEstatusTimbrado = Estatustimbrado.IDEstatusTimbrado        
		LEFT JOIN Sat.tblCatTiposRegimen TiposRegimen   with (nolock)     
			on Timbrado.IDTipoRegimen = TiposRegimen.IDTipoRegimen         
		LEFT Join Seguridad.tblUsuarios Usuarios  with (nolock)      
			on Timbrado.IDUsuario = Usuarios.IDUsuario         
		left join IMSS.TblVigenciaEmpleado M with (nolock)
			on M.IDEmpleado = Historial.IDEmpleado         
		LEFT JOIN [IMSS].[tblMovAfiliatorios] MOV  with (nolock)      
			ON M.IDMovAfiliatorio = MOV.IDMovAfiliatorio        
           
	WHERE  ((@Timbrado = 0 and isnull(Estatustimbrado.Descripcion,'NUEVO') in ('NUEVO','CANCELADO','ERROR')         
	   OR   (@Timbrado = 1 and Estatustimbrado.Descripcion in ('TIMBRADO')))         
	  AND Historial.IDPeriodo = @IDPeriodo)        
	  AND Historial.IDHistorialEmpleadoPeriodo = @Folio

        
        
END
GO
