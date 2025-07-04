USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los recibos de nómina pendientes de timbrado Minima Información
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
CREATE PROCEDURE [Facturacion].[spBuscarPendientesTimbradoMinimo] --2, 0        
(        
    @Timbrado bit      
   ,@Asimilado bit   = 0
   ,@dtFiltros [Nomina].[dtFiltrosRH] readonly
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
		 ,@IDPeriodo int          
         ,@IDIdioma varchar(20)
	    ;

        select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')


		SET @IDPeriodo = (Select top 1 CAST(Value as int) from @dtFiltros where Catalogo = 'IDPeriodoInicial')


	select top 1         
		@IDPeriodo = p.IDPeriodo ,@IDTipoNomina= p.IDTipoNomina,@Ejercicio = p.Ejercicio,@ClavePeriodo = p.ClavePeriodo,@DescripcionPeriodo =  p.Descripcion         
		,@FechaInicioPago = p.FechaInicioPago,@FechaFinPago = p.FechaFinPago,@FechaInicioIncidencia = p.FechaInicioIncidencia,@FechaFinIncidencia=  p.FechaFinIncidencia         
		,@Dias = p.Dias,@AnioInicio = p.AnioInicio,@AnioFin = p.AnioFin,@MesInicio = p.MesInicio,@MesFin = p.MesFin         
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin         
		,@General = p.General,@Finiquito = p.Finiquito,@Especial = p.Especial,@Cerrado = p.Cerrado         
	from Nomina.tblCatPeriodos p        
	Where p.IDPeriodo = @IDPeriodo       
	 
	
	select Historial.IDHistorialEmpleadoPeriodo as Folio       
		,isnull(Historial.IDPeriodo,0) as IDPeriodo      
		,ISNULL(Periodos.IDTipoNomina,0) as IDTipoNomina  
		,ISNULL(Periodos.ClavePeriodo,'') as ClavePeriodo  
		--,Periodos.Ejercicio        
		--,Periodos.ClavePeriodo        
		--,Periodos.Descripcion        
		--,cast(Periodos.FechaInicioPago as date)   FechaInicioPago      
		--,cast(Periodos.FechaFinPago as date) FechaFinPago        
		--,Periodicidad.Codigo as CodigoPeriodicidadPago        
		--,Periodicidad.Descripcion as PeriodicidadPago        
		--,CEILING( isnull((Select CASE WHEN ImporteTotal1> 0 then  ImporteTotal1 else Periodos.Dias END        
		--		   from Nomina.tblDetallePeriodo dp        
		--			inner join Nomina.tblCatConceptos c on DP.IDConcepto = c.IDConcepto        
		--		   where dp.IDEmpleado = Historial.IDEmpleado         
		--			and dp.IDPeriodo = Historial.IDPeriodo        
		--			and c.Codigo = '005'        
		--		   ),Periodos.Dias)) as DiasPagados        
		--,CASE WHEN (Periodos.Especial = 1 )  Then (Select Top 1 Codigo FROM Sat.tblCatTiposNomina Where IDTipoNomina = 1)        
		--	  ELSE (Select Top 1 Codigo FROM Sat.tblCatTiposNomina Where IDTipoNomina = 1)        
		--	  END TipoNomina        
		--,isnull(TipoNomina.IDTipoNomina,0) AS IDTipoNomina        
		,isnull(Historial.IDEmpleado,0) as IDEmpleado        
		,Empleado.ClaveEmpleado        
		,UPPER(TRIM(COALESCE(Empleado.Paterno,''))+' '+ TRIM(CASE WHEN ISNULL(Empleado.Materno,'') <> '' THEN ' '+COALESCE(Empleado.Materno,'') ELSE '' END)  +' '+TRIM(COALESCE(Empleado.Nombre,''))+ CASE WHEN TRIM(ISNULL(Empleado.SegundoNombre,'')) <> '' THEN ' '+TRIM(COALESCE(Empleado.SegundoNombre,'')) ELSE '' END) AS NOMBRECOMPLETO        
		--,COALESCE(Empleado.Paterno,'')  as Paterno        
		--,COALESCE(Empleado.Materno,'')  as Materno        
		--,COALESCE(Empleado.Nombre,'')+' '+COALESCE(Empleado.SegundoNombre,'') as Nombres        
		--,Empleado.FechaNacimiento        
		--,Municipios.Codigo as CodigoMunicipioNacimiento        
		--,Estados.NombreEstado as EstadoNacimiento        
		--,Paises.Codigo as CodigoPaisNacimiento        
		--,Empleado.Sexo as Sexo        
		,Empleado.RFC        
		,Empleado.CURP        
		,Empleado.IMSS        
		--,CAST(Empleado.FechaPrimerIngreso as Date) FechaPrimerIngreso       
		--,Cast(Empleado.FechaIngreso as date)  FechaIngreso        
		,Cast(Empleado.FechaAntiguedad as date)  FechaAntiguedad      
		--,COALESCE('P'+CAST(((DATEDIFF(DAY,Empleado.FechaAntiguedad,Periodos.FechaFinPago)+1)/7) AS Varchar)+'W','') as Antiguedad       
		--,Facturacion.fnAntiguedadSAT(Empleado.FechaAntiguedad,Periodos.FechaFinPago) as Antiguedad
		--,Empleado.Sindicalizado        
		--,ISNULL(MOV.SalarioDiario,0.00) as SalarioDiario         
		--,ISNULL(MOV.SalarioIntegrado,0.00) as SalarioIntegrado         
		--,isnull(Empleado.IDJornadaLaboral,0) as    IDJornadaLaboral     
		--,COALESCE(Jornada.Codigo,'') CodigoJornada        
		--,COALESCE(Jornada.Codigo,'')+' '+COALESCE(Jornada.Descripcion,'') as Jornada        
		--,ISNULL(Bancos.IDBanco,0) as IDBanco        
		--,COALESCE(Bancos.Codigo,'')+' '+COALESCE(Bancos.Descripcion,'') as Banco        
		--,COALESCE(Pago.Cuenta,'') as Cuenta        
		--,COALESCE(Pago.Sucursal,'') as SucursalBancaria        
		--,ISNULL(Layout.IDLayoutPago,0) as IDLayoutPago        
		--,COALESCE(Layout.Descripcion,'') as LayoutPago         
        
		--,ISNULL(Historial.IDCentroCosto,0) as IDCentroCosto        
		--,COALESCE(CentroCosto.Codigo,'')+' '+COALESCE(CentroCosto.Descripcion,'') as CentroCosto        
		,ISNULL(Historial.IDDepartamento,0) as IDDepartamento        
		,COALESCE(Departamentos.Codigo,'')+' '+COALESCE(JSON_VALUE(Departamentos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'') as Departamento        
		,ISNULL(Historial.IDSucursal,0) as IDSucursal        
		,COALESCE(Sucursales.Codigo,'')+' '+COALESCE(Sucursales.Descripcion,'') as Sucursal        
		,ISNULL(Historial.IDPuesto,0) as IDPuesto        
		,COALESCE(Puestos.Codigo,'')+' '+COALESCE(JSON_VALUE(Puestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'') as Puesto        
		--,ISNULL(Historial.IDRegPatronal,0) as IDRegPatronal        
		--,COALESCE(RegPatronal.RegistroPatronal,'') as RegistroPatronal        
		--,COALESCE(RegPatronal.RazonSocial,'') as RazonSocial        
		--,COALESCE(Riesgos.Codigo,'') as Riesgo        
		--,ISNULL(Historial.IDCliente,0) as IDCliente        
		--,COALESCE(Clientes.NombreComercial,'') as Cliente        
		,ISNULL(Historial.IDEmpresa,0) as IDEmpresa        
		,COALESCE(Empresas.RFC,'') as RFCEmisor        
		,COALESCE(Empresas.NombreComercial,'') as Empresa        
		--,ISNULL(Historial.IDRazonSocial,0) as IDBeneficiarioSubcontratacion        
		--,COALESCE(RS.RFC,'') as RFCBeneficiarioSubcontratacion        
        
		--,ISNULL(Empresas.IDCodigoPostal,0) as IDCodigoPostal        
		--,COALESCE(CP.CodigoPostal,'') as CodigoPostal        
		--,COALESCE(Estado.Codigo,'') as EntidadFederativa        
            
		--,ISNULL(Empresas.IDRegimenFiscal,0) as IDRegimenFiscal        
		--,COALESCE(RegimenesFiscales.Codigo,'') as CodigoRegimenFiscal        
		--,COALESCE(RegimenesFiscales.Descripcion,'') as RegimenFiscal        
		--,ISNULL(Empresas.IDOrigenRecurso,0) as IDOrigenRecurso        
		--,COALESCE(OrigenesRecursos.Codigo,'') as CodigoOrigenRecurso        
		--,COALESCE(OrigenesRecursos.Descripcion,'') as OrigenRecurso        
        
        
		--,ISNULL(Historial.IDArea,0) as IDArea        
		--,COALESCE(Areas.Codigo,'')+' '+COALESCE(Areas.Descripcion,'') as Area        
		--,ISNULL(Historial.IDDivision,0) as IDDivision        
		--,COALESCE(Divisiones.Codigo,'')+' '+COALESCE(Divisiones.Descripcion,'') as Division        
		--,ISNULL(Historial.IDClasificacionCorporativa,0) as IDClasificacionCorporativa        
		--,COALESCE(clasificaciones.Codigo,'')+' '+COALESCE(clasificaciones.Descripcion,'') as ClasificacionCorporativa        
		--,ISNULL(Historial.IDRegion,0) as IDRegion        
		--,COALESCE(Regiones.Codigo,'')+' '+COALESCE(Regiones.Descripcion,'') as Region        
		--,ISNULL(Timbrado.IDTimbrado,0) as IDTimbrado        
		--,ISNULL(Timbrado.IDTipoRegimen,0) as IDTipoRegimen        
		--,COALESCE(TiposRegimen.Codigo,'')as CodigoTipoRegimen        
		--,COALESCE(TiposRegimen.Codigo,'')+' '+COALESCE(TiposRegimen.Descripcion,'') as TipoRegimen        
		,CASE WHEN isnull(Historial.Asimilado,0) = 0 THEN  ISNULL(dp.ImporteTotal1,0.00)
			ELSE ISNULL(dpAsimilado.ImporteTotal1,0.00) 
			END as Total
        ,CASE WHEN isnull(Historial.Asimilado,0) = 0 THEN  ISNULL(dpTotPercepciones.ImporteTotal1,0.00)
			ELSE ISNULL(dpAsimiladoTotPercepciones.ImporteTotal1,0.00) 
			END as TotalPercepciones
        ,CASE WHEN isnull(Historial.Asimilado,0) = 0 THEN  ISNULL(dpTotDeducciones.ImporteTotal1,0.00)
            ELSE ISNULL(dpAsimiladoTotDeducciones.ImporteTotal1,0.00) 
            END as TotalDeducciones
		,CASE WHEN isnull(Historial.Asimilado,0) = 0 THEN  COALESCE(c.Descripcion,'') 
			ELSE COALESCE(cAsimilado.Descripcion,'') 
			END as Concepto     
		,COALESCE(Timbrado.UUID,'') as UUID         
		,COALESCE(Timbrado.ACUSE,'') as ACUSE         
		,CASE WHEN ISNULL(ConfigEmpresa.TieneCertificado,0) = 1 THEN ISNULL(Timbrado.IDEstatusTimbrado,1) ELSE 5 END as IDEstatusTimbrado        
		,CASE WHEN ISNULL(ConfigEmpresa.TieneCertificado,0) = 1 THEN COALESCE(EstatusTimbrado.Descripcion,'NUEVO') ELSE 'NO VALIDO' END as EstatusTimbrado        
		,COALESCE(Timbrado.Fecha,'') as Fecha        
		--,ISNULL(Timbrado.IDUsuario,0) as IDUsuario        
		--,COALESCE(Usuarios.Cuenta,'') as Usuario        
		,COALESCE(Timbrado.CodigoError,'') as CodigoError        
		,CASE WHEN ISNULL(ConfigEmpresa.TieneCertificado,0) = 1 then COALESCE(Timbrado.Error,'') ELSE 'LA RAZÓN SOCIAL A LA QUE PERTENECE EL COLABORADOR NO TIENE CERTIFICADOS CONFIGURADOS PARA EL TIMBRADO' END as Error        
        ,ISNULL(Historial.Asimilado,0) as Asimilado   
		,Facturacion.fnCoreGetCustomID(Historial.IDHistorialEmpleadoPeriodo) as CustomID
        ,App.fnGetLatestEmailEvent(Historial.IDHistorialEmpleadoPeriodo,'[Nomina].[tblHistorialesEmpleadosPeriodos]') as UltimoEstatusEmail   
	From Nomina.tblHistorialesEmpleadosPeriodos Historial     
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = Historial.IDEmpleado and dfe.IDUsuario = @IDUsuario   
		Inner join Nomina.tblCatPeriodos Periodos on Historial.IDPeriodo = Periodos.IDPeriodo        
		Inner Join Nomina.tblCatTipoNomina TipoNomina on TipoNomina.IDTipoNomina = Periodos.IDTipoNomina        
		INNER JOIN Sat.tblCatPeriodicidadesPago Periodicidad on Periodicidad.IDPeriodicidadPago = TipoNomina.IDPeriodicidadPago        
		--Inner join RH.tblEmpleados Empleado on Historial.IDEmpleado = Empleado.IDEmpleado        
		Inner join RH.tblEmpleadosMaster Empleado on Historial.IDEmpleado = Empleado.IDEmpleado 
		Left Join Sat.tblCatMunicipios Municipios on Empleado.IDMunicipioNacimiento = Municipios.IDMunicipio         
		Left Join Sat.tblCatEstados Estados on Empleado.IDEstadoNacimiento = Estados.IDEstado        
		Left Join Sat.tblCatPaises Paises on Empleado.IDPaisNacimiento = Paises.IDPais        
		Left Join Sat.tblCatTiposJornada jornada on Empleado.IDJornadaLaboral = Jornada.IDTipoJornada        
		--Left Join RH.tblPagoEmpleado Pago on Empleado.IDEmpleado = Pago.IDEmpleado        
        
		--Left Join Nomina.tblLayoutPago Layout on Pago.IDLayoutPago = Layout.IDLayoutPago        
		--Left Join Sat.tblCatBancos Bancos on Bancos.IDBanco = Pago.IDBanco  
		Left join Nomina.tblDetallePeriodo dp on dp.IDPeriodo = Periodos.IDPeriodo
			and dp.IDEmpleado = Historial.IDEmpleado
			and dp.IDConcepto in (select IDConcepto from Nomina.tblCatConceptos where IDTipoConcepto = 5) -- PAGO
		left join Nomina.tblCatConceptos c on dp.IDConcepto = c.IDConcepto  
        Left join Nomina.tblDetallePeriodo dpTotPercepciones on dpTotPercepciones.IDPeriodo = Periodos.IDPeriodo
			and dpTotPercepciones.IDEmpleado = Historial.IDEmpleado
			and dpTotPercepciones.IDConcepto in (select IDConcepto from Nomina.tblCatConceptos where Codigo = '550') -- TOTAL PERCEPCIONES
        Left join Nomina.tblDetallePeriodo dpTotDeducciones on dpTotDeducciones.IDPeriodo = Periodos.IDPeriodo
			and dpTotDeducciones.IDEmpleado = Historial.IDEmpleado
			and dpTotDeducciones.IDConcepto in (select IDConcepto from Nomina.tblCatConceptos where Codigo = '560') -- TOTAL DEDUCCIONES	
		Left join Nomina.tblDetallePeriodo dpAsimilado on dpAsimilado.IDPeriodo = Periodos.IDPeriodo
			and dpAsimilado.IDEmpleado = Historial.IDEmpleado
			and dpAsimilado.IDConcepto in (select IDConcepto from Nomina.tblCatConceptos where IDTipoConcepto = 11) -- PAGO ASIMILADOS
		left join Nomina.tblCatConceptos cAsimilado on dpAsimilado.IDConcepto = cAsimilado.IDConcepto  
        Left join Nomina.tblDetallePeriodo dpAsimiladoTotPercepciones on dpAsimiladoTotPercepciones.IDPeriodo = Periodos.IDPeriodo
			and dpAsimiladoTotPercepciones.IDEmpleado = Historial.IDEmpleado
			and dpAsimiladoTotPercepciones.IDConcepto in (select IDConcepto from Nomina.tblCatConceptos where Codigo = 'A550') -- TOTAL PERCEPCIONES ASIMILADOS
        Left join Nomina.tblDetallePeriodo dpAsimiladoTotDeducciones on dpAsimiladoTotDeducciones.IDPeriodo = Periodos.IDPeriodo
			and dpAsimiladoTotDeducciones.IDEmpleado = Historial.IDEmpleado
			and dpAsimiladoTotDeducciones.IDConcepto in (select IDConcepto from Nomina.tblCatConceptos where Codigo = 'A560') -- TOTAL DEDUCCIONES ASIMILADOS
		Left join RH.tblCatCentroCosto CentroCosto on Historial.IDCentroCosto = CentroCosto.IDCentroCosto        
		Left Join RH.tblCatDepartamentos Departamentos on Historial.IDDepartamento = Departamentos.IDDepartamento        
		Left Join RH.tblCatSucursales Sucursales on Historial.IDSucursal = Sucursales.IDSucursal        
		Left Join RH.tblCatPuestos Puestos on Historial.IDPuesto = Puestos.IDPuesto        
		Left Join RH.TblCatRegPatronal RegPatronal on Historial.IDRegPatronal = RegPatronal.IDRegPatronal        
		Left Join Sat.tblCatRiesgosPuesto Riesgos on Riesgos.IDRiesgoPuesto = RegPatronal.IDClaseRiesgo        
		Left Join RH.tblCatClientes Clientes on Historial.IDCliente = Clientes.IDCliente        
		Left Join RH.tblEmpresa Empresas on Historial.IDEmpresa = Empresas.IDEmpresa        
		Left Join Sat.tblCatCodigosPostales CP on CP.IDCodigoPostal = Empresas.IDCodigoPostal        
		Left Join Sat.tblCatEstados Estado on Empresas.IDEstado = Estado.IDEstado        
		Left Join Sat.tblCatRegimenesFiscales RegimenesFiscales on RegimenesFiscales.IDRegimenFiscal = Empresas.IDRegimenFiscal        
		Left Join Sat.tblCatOrigenesRecursos OrigenesRecursos on OrigenesRecursos.IDOrigenRecurso = Empresas.IDOrigenRecurso        
		Left Join RH.tblCatArea Areas on Historial.IDArea = Areas.IDArea        
		LEft Join RH.tblCatDivisiones Divisiones on Historial.IDDivision = Divisiones.IDDivision        
		Left Join RH.tblCatClasificacionesCorporativas clasificaciones on Historial.IDclasificacionCorporativa = Clasificaciones.IDClasificacionCorporativa        
		Left Join RH.tblCatRegiones Regiones on Historial.IDRegion = Regiones.IDRegion        
		Left Join RH.tblCatRazonesSociales RS on Historial.IDRazonSocial = RS.IDRazonSocial 
        Left join Facturacion.tblCatConfigEmpresa ConfigEmpresa on Historial.IDEmpresa = ConfigEmpresa.IDEmpresa       
		Left Join Facturacion.tblTimbrado Timbrado on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo and timbrado.Actual = 1        
		LEFT join Facturacion.tblCatEstatusTimbrado Estatustimbrado on Timbrado.IDEstatusTimbrado = Estatustimbrado.IDEstatusTimbrado        
		LEFT JOIN Sat.tblCatTiposRegimen TiposRegimen on Timbrado.IDTipoRegimen = TiposRegimen.IDTipoRegimen         
		LEFT Join Seguridad.tblUsuarios Usuarios on Timbrado.IDUsuario = Usuarios.IDUsuario         
		 ,(select IDEmpleado, FechaAlta, FechaBaja,        
			  case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso        
			  ,IDMovAfiliatorio     
			  from (select 
						distinct tm.IDEmpleado,        
						case when(IDEmpleado is not null) then (select top 1 Fecha         
																 from [IMSS].[tblMovAfiliatorios]  mAlta        
																	join [IMSS].[tblCatTipoMovimientos]   c  on mAlta.IDTipoMovimiento=c.IDTipoMovimiento        
																 where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'          
																 Order By mAlta.Fecha Desc , c.Prioridad DESC ) end as FechaAlta,        
						case when (IDEmpleado is not null) then (select top 1 Fecha         
																 from [IMSS].[tblMovAfiliatorios]  mBaja        
																	join [IMSS].[tblCatTipoMovimientos]   c  on mBaja.IDTipoMovimiento=c.IDTipoMovimiento        
																 where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'          
																	and mBaja.Fecha <= @FechaFinPago         
																order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,        
						case when (IDEmpleado is not null) then (select top 1 Fecha         
																 from [IMSS].[tblMovAfiliatorios]  mReingreso        
																	join [IMSS].[tblCatTipoMovimientos]   c  on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento        
																 where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'          
																	and mReingreso.Fecha <= @FechaFinPago         
																order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso          
						,(Select top 1 mSalario.IDMovAfiliatorio 
							from [IMSS].[tblMovAfiliatorios]  mSalario        
								join [IMSS].[tblCatTipoMovimientos]   c  on mSalario.IDTipoMovimiento=c.IDTipoMovimiento        
							where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')         
							order by mSalario.Fecha desc ) as IDMovAfiliatorio                                         
					from [IMSS].[tblMovAfiliatorios]  tm ) mm ) M         
			left join [IMSS].[tblMovAfiliatorios] MOV ON M.IDMovAfiliatorio = MOV.IDMovAfiliatorio                   
	WHERE  ((@Timbrado = 0 and isnull(Estatustimbrado.Descripcion,'NUEVO') in ('NUEVO','CANCELADO','ERROR')         
			OR   (@Timbrado = 1 and Estatustimbrado.Descripcion in ('TIMBRADO')))         
		and Historial.IDPeriodo = @IDPeriodo)    
		and isnull(Historial.Asimilado,0) = isnull(@Asimilado,0)
		and MOV.IDEmpleado = Empleado.IDEmpleado        
		and ((Empleado.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))              
		and ((Historial.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))              
		and ((Historial.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))              
		and ((Historial.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))              
		and ((Empleado.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))           
		and ((Historial.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))          
		and ((Empleado.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))        
		and ((Historial.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))        
		and ((Historial.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))       
		and ((Historial.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))
        and ((Historial.IDArea in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Areas' and isnull(Value,'')<>'')))        
		and ((Historial.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))               
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>'')))      
             
		and ((              
			((COALESCE(Empleado.ClaveEmpleado,'')+' '+ COALESCE(Empleado.Paterno,'')+' '+COALESCE(Empleado.Materno,'')+', '+COALESCE(Empleado.Nombre,'')+' '+COALESCE(Empleado.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')                
 
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))      

        
        
END
GO
