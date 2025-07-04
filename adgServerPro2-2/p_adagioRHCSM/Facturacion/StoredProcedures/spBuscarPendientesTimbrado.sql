USE [p_adagioRHCSM]
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
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu		Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
										Seguridad.tblDetalleFiltrosEmpleadosUsuarios
2022-10-05			Julio Castillo		Se le modificó el campo DiasPagados segun la guia de llenado (NumDiasPagados) 
										http://omawww.sat.gob.mx/tramitesyservicios/Paginas/documentos/guianomina12_3_3_07082017.pdf
2022-12-09			Andrea Zainos		Cambio para que los paths de los recibos de nomina los obtenga desde el catalogo Reportes.tblCatReportesBasicos
2023-02-20			Jose Roman			Se agrego LTRIM y RTRIM al nombre Completo SAT para que coincidan con el registro del SAT cuandi
										solo tiene un apellido.
2023-05-15			Jose Roman			Mejoria adicional para las personas con un solo apellido o un solo nombre, se incluyen casos de pruebas adicionales.
2023-12-08			Jose Roman			Corrección para tomar el salario diario e integrado correcto con respecto a las fechas del periodo que se este ejecutando.
2024-01-08			Julio Castillo		Configuración personalizada para modificar la periodicidad de pago en finiquitos y tambien el Tipo de Nómina.
2024-05-08			Aneudy Abreu		Agrega filtro por IDEmpleado a la tabla de MovAfiliatorios
2024-07-16			Alejandro Paredes   Agrega traduccion a clasificaciones corporativas
***************************************************************************************************/

/*
	EXEC [Facturacion].[spBuscarPendientesTimbrado]75893,751,1,1
*/

CREATE PROCEDURE [Facturacion].[spBuscarPendientesTimbrado](        
    @Folio int      
   ,@IDPeriodo int      
   ,@Timbrado bit      
   ,@IDUsuario int
)        
AS        
BEGIN        
	DECLARE         
		 @IDEmpleado int
		 ,@IDTipoNomina int         
		 ,@FechaInicioPago date         
		 ,@FechaFinPago date         
		 ,@IDIdioma varchar(20)
         ,@ConfigPeriodicidadFiniquito bit
         ,@ID_TIPO_JORNADA INT
         ,@CODIGO_JORNADA_DIURNA VARCHAR(20)
         ,@DESCRIPCION_JORNADA_DIURNA VARCHAR(50)= 'DIURNA'
         
	;


	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
    select @ConfigPeriodicidadFiniquito = Cast (valor as bit ) from app.tblConfiguracionesGenerales where IDConfiguracion = 'PeriodicidadPagoFiniquito'

    SELECT @ID_TIPO_JORNADA        =   IDTipoJornada
          ,@CODIGO_JORNADA_DIURNA  =   Codigo
    FROM SAT.tblCatTiposJornada
    WHERE Descripcion=@DESCRIPCION_JORNADA_DIURNA

	select top 1         
		@IDPeriodo = p.IDPeriodo 
		,@IDTipoNomina= p.IDTipoNomina
		,@FechaInicioPago = p.FechaInicioPago
		,@FechaFinPago = p.FechaFinPago
	from Nomina.tblCatPeriodos p        
	Where p.IDPeriodo = @IDPeriodo 

	if object_id('tempdb..#tempMovimientosAfiliatorios') is not null drop table #tempMovimientosAfiliatorios
	if object_id('tempdb..#tempCatTipoMovimiento') is not null drop table #tempCatTipoMovimiento
	if object_id('tempdb..#tempMovAfil') is not null drop table #tempMovAfil
	if object_id('tempdb..#tempLayouts') is not null drop table #tempLayouts

	select *
		into #tempLayouts
	from  Nomina.tblLayoutPago lp with(nolock)
	WHERE
		lp.IDConcepto in (select IDConcepto from Nomina.tblCatConceptos where codigo in ('601','A601','604'))
		or lp.IDConceptoFiniquito in (select IDConcepto from Nomina.tblCatConceptos where codigo in ('601','A601','604'))
			


	CREATE TABLE #tempMovimientosAfiliatorios(
		IDMovAfiliatorio	int
		,Fecha				date
		,IDEmpleado			int
		,IDTipoMovimiento	int
		,FechaIMSS			date
		,FechaIDSE			date
		,IDRazonMovimiento	int
		,SalarioDiario		decimal(18,2)
		,SalarioIntegrado	decimal(18,2)
		,SalarioVariable	decimal(18,2)
		,SalarioDiarioReal	decimal(18,2)
		,IDRegPatronal		int
		,RespetarAntiguedad	bit
		,FechaAntiguedad	Date
		,IDTipoPrestacion	int
		,INDEX idx_tempMovAfil NONCLUSTERED ([IDEmpleado],[IDTipoMovimiento],[Fecha]) INCLUDE ([RespetarAntiguedad])
	)

	select @IDEmpleado = hep.IDEmpleado
	from Nomina.tblHistorialesEmpleadosPeriodos hep with (nolock)
	where hep.IDHistorialEmpleadoPeriodo = @Folio

	SELECT 
		IDTipoMovimiento
		,Codigo
		,Descripcion
		,Prioridad
	INTO #tempCatTipoMovimiento
	FROM IMSS.tblCatTipoMovimientos WITH(NOLOCK)
	 
	INSERT INTO #tempMovimientosAfiliatorios
	SELECT 
	 m.IDMovAfiliatorio	
	,m.Fecha				
	,m.IDEmpleado			
	,m.IDTipoMovimiento	
	,m.FechaIMSS			
	,m.FechaIDSE			
	,m.IDRazonMovimiento	
	,m.SalarioDiario		
	,m.SalarioIntegrado	
	,m.SalarioVariable	
	,m.SalarioDiarioReal	
	,m.IDRegPatronal		
	,m.RespetarAntiguedad	
	,m.FechaAntiguedad	
	,m.IDTipoPrestacion	
	FROM IMSS.tblMovAfiliatorios m WITH(NOLOCK)
	where m.IDEmpleado = @IDEmpleado

	select mm.IDEmpleado
		,FechaAlta
		,FechaBaja
		,case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso
		,FechaReingresoAntiguedad
		,mm.IDMovAfiliatorio
		,mmSueldos.SalarioDiario
		,mmSueldos.SalarioVariable
		,mmSueldos.SalarioIntegrado
		,mmSueldos.SalarioDiarioReal
	into #tempMovAfil
	from (select distinct tm.IDEmpleado,
			case when(tm.IDEmpleado is not null) then (select  MAX(Fecha) as Fecha
						from #tempMovimientosAfiliatorios mAlta WITH(NOLOCK)
					join #tempCatTipoMovimiento c WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento
						where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'
						--Order By mAlta.Fecha Desc , c.Prioridad DESC 
						) end as FechaAlta,
			case when (tm.IDEmpleado is not null) then (select MAX(Fecha) as Fecha
						from #tempMovimientosAfiliatorios  mBaja WITH(NOLOCK)
					join #tempCatTipoMovimiento  c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento
						where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'
					and mBaja.Fecha <= FORMAT(@FechaFinPago,'yyyy-MM-dd')
			--order by mBaja.Fecha desc, C.Prioridad desc
			) end as FechaBaja,
			case when (tm.IDEmpleado is not null) then (select  MAX(Fecha) as Fecha
						from #tempMovimientosAfiliatorios  mReingreso WITH(NOLOCK)
					join #tempCatTipoMovimiento   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento
						where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo in('R','A')
					and mReingreso.Fecha <= FORMAT(@FechaFinPago,'yyyy-MM-dd')
					--and isnull(mReingreso.RespetarAntiguedad,0) <> 1
					--order by mReingreso.Fecha desc, C.Prioridad desc
					) end as FechaReingreso
			,case when (tm.IDEmpleado is not null) then (select MAX(Fecha) as Fecha
						from #tempMovimientosAfiliatorios  mReingresoAnt WITH(NOLOCK)
					join #tempCatTipoMovimiento   c  WITH(NOLOCK) on mReingresoAnt.IDTipoMovimiento=c.IDTipoMovimiento
						where mReingresoAnt.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','R')
					and mReingresoAnt.Fecha <= FORMAT(@FechaFinPago,'yyyy-MM-dd')
					and isnull(mReingresoAnt.RespetarAntiguedad,0) <> 1
					--order by mReingresoAnt.Fecha desc, C.Prioridad desc
					) end as FechaReingresoAntiguedad
			,(Select top 1 mSalario.IDMovAfiliatorio from #tempMovimientosAfiliatorios  mSalario WITH(NOLOCK)
					join #tempCatTipoMovimiento   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento
						where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')
						and mSalario.Fecha <= FORMAT(@FechaFinPago,'yyyy-MM-dd')
						order by mSalario.Fecha desc ) as IDMovAfiliatorio
		from #tempMovimientosAfiliatorios tm with (nolocK)
			--inner join #dtEmpleados e on e.IDEmpleado = tm.IDEmpleado
		) mm
			JOIN #tempMovimientosAfiliatorios mmSueldos with (nolocK) on mm.IDMovAfiliatorio = mmSueldos.IDMovAfiliatorio
	where ( mm.FechaAlta<=@FechaFinPago and (mm.FechaBaja>=@FechaInicioPago or mm.FechaBaja is null)) or (mm.FechaReingreso<=@FechaFinPago)

	select 
		Historial.IDHistorialEmpleadoPeriodo        
		,isnull(Historial.IDPeriodo,0) as IDPeriodo        
		,Periodos.Ejercicio        
		,Periodos.ClavePeriodo        
		,Periodos.Descripcion        
		,cast(Periodos.FechaInicioPago as date)   FechaInicioPago      
		,cast(Periodos.FechaFinPago as date) FechaFinPago        
		,case 
				when isnull(Periodos.Especial,0) = 1 then '99' 
				when isnull(Periodos.Finiquito,0) = 1 and isnull(@ConfigPeriodicidadFiniquito,0) = 1 then '99'
			else Periodicidad.Codigo 
			end as CodigoPeriodicidadPago 
		,case 
				when isnull(Periodos.Especial,0) = 1 then 'Otra Periodicidad' 
				when isnull(Periodos.Finiquito,0) = 1 and isnull(@ConfigPeriodicidadFiniquito,0) = 1 then 'Otra Periodicidad'
			else Periodicidad.Descripcion 
			end as PeriodicidadPago       
		,CAST(( isnull((Select CASE WHEN isnull(ImporteTotal1,0)> 0 then  ImporteTotal1 else 1 END        
				   from Nomina.tblDetallePeriodo dp        
					inner join Nomina.tblCatConceptos c on DP.IDConcepto = c.IDConcepto        
				   where dp.IDEmpleado = Historial.IDEmpleado         
					and dp.IDPeriodo = Historial.IDPeriodo        
					and c.Codigo = '005'        
				   ),1))as Decimal(18,3)) as DiasPagados        
		,CASE 
				WHEN (Periodos.Especial = 1 )  Then (Select Top 1 Codigo FROM Sat.tblCatTiposNomina Where IDTipoNomina = 2)  
				WHEN isnull(Periodos.Finiquito,0) = 1 and isnull(@ConfigPeriodicidadFiniquito,0) = 1 Then (Select Top 1 Codigo FROM Sat.tblCatTiposNomina Where IDTipoNomina = 2)   
			  ELSE (Select Top 1 Codigo FROM Sat.tblCatTiposNomina Where IDTipoNomina = 1)        
			  END TipoNomina        
		,isnull(TipoNomina.IDTipoNomina,0) AS IDTipoNomina        
		,isnull(Historial.IDEmpleado,0) as IDEmpleado        
		,Empleado.ClaveEmpleado      
		-- ,REPLACE(RTRIM(LTRIM(
		-- 		TRIM(COALESCE(Empleado.Nombre,''))+ 
		-- 		CASE WHEN TRIM(ISNULL(Empleado.SegundoNombre,'')) <> '' THEN ' '+TRIM(COALESCE(Empleado.SegundoNombre,'')) ELSE '' END +' '+
		-- 		TRIM(COALESCE(Empleado.Paterno,''))+' '+
		-- 		TRIM(CASE WHEN ISNULL(Empleado.Materno,'') <> '' THEN ' '+COALESCE(Empleado.Materno,'') ELSE '' END)
		-- 		)),'  ',' ') AS NOMBRECOMPLETOSAT               
		--,UPPER(TRIM(COALESCE(Empleado.Paterno,''))+' '+ TRIM(CASE WHEN ISNULL(Empleado.Materno,'') <> '' THEN ' '+COALESCE(Empleado.Materno,'') ELSE '' END)  +' '+TRIM(COALESCE(Empleado.Nombre,''))+ CASE WHEN TRIM(ISNULL(Empleado.SegundoNombre,'')) <> '' THEN ' '+TRIM(COALESCE(Empleado.SegundoNombre,'')) ELSE '' END)  AS NOMBRECOMPLETO        
		,RH.fnFormatNombreCompletoSAT(Empleado.nombre,Empleado.segundoNombre,Empleado.Paterno,Empleado.Materno) as NOMBRECOMPLETOSAT  
        ,RH.fnFormatNombreCompleto(Empleado.nombre,Empleado.segundoNombre,Empleado.Paterno,Empleado.Materno) as NOMBRECOMPLETO
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
		,isnull( CASE WHEN Empleado.IDJornadaLaboral = 0 THEN NULL ELSE Empleado.IDJornadaLaboral END ,@ID_TIPO_JORNADA) as IDJornadaLaboral     
		,COALESCE(Jornada.Codigo,@CODIGO_JORNADA_DIURNA) CodigoJornada        
		,COALESCE(Jornada.Codigo,@CODIGO_JORNADA_DIURNA)+' '+COALESCE(Jornada.Descripcion,@DESCRIPCION_JORNADA_DIURNA) as Jornada        
		--,ISNULL(Bancos.IDBanco,0) as IDBanco        
		--,COALESCE(Bancos.Codigo,'')+' '+COALESCE(Bancos.Descripcion,'') as Banco        
		--,COALESCE(Pago.Cuenta,'') as Cuenta        
		--,COALESCE(Pago.Sucursal,'') as SucursalBancaria        
		--,ISNULL(Layout.IDLayoutPago,0) as IDLayoutPago        
		--,COALESCE(Layout.Descripcion,'') as LayoutPago         
        ,ISNULL(Bancos.codigo,'') as Banco
		,ISNULL(clde.CuentaBancaria,'') as CuentaBancaria


		,ISNULL(Historial.IDCentroCosto,0) as IDCentroCosto        
		,COALESCE(CentroCosto.Codigo,'')+' '+COALESCE(CentroCosto.Descripcion,'') as CentroCosto        
		,ISNULL(Historial.IDDepartamento,0) as IDDepartamento        
		,COALESCE(Departamentos.Codigo,'')+' '+COALESCE(Departamentos.Descripcion,'') as Departamento        
		,ISNULL(Historial.IDSucursal,0) as IDSucursal        
		,COALESCE(Sucursales.Codigo,'')+' '+COALESCE(Sucursales.Descripcion,'') as Sucursal        
		,ISNULL(Historial.IDPuesto,0) as IDPuesto        
		,COALESCE(Puestos.Codigo,'')+' '+COALESCE(JSON_VALUE(Puestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'') as Puesto        
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
		,COALESCE(JSON_VALUE(Clientes.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')),'') as Cliente        
		,ISNULL(Historial.IDEmpresa,0) as IDEmpresa        
		,COALESCE(Empresas.RFC,'') as RFCEmisor        
		,COALESCE(Empresas.NombreComercial,'') as Empresa        
		,ISNULL(Historial.IDRazonSocial,0) as IDBeneficiarioSubcontratacion        
		,COALESCE(RS.RFC,'') as RFCBeneficiarioSubcontratacion        
        
		,ISNULL(Empresas.IDCodigoPostal,0) as IDCodigoPostal        
		,COALESCE(CP.CodigoPostal,'') as CodigoPostal   
		,COALESCE(CP.TimeZone,'Central Standard Time (Mexico)') as TimeZone   
		,COALESCE(Estado.Codigo,'') as EntidadFederativa        
            
		,ISNULL(Empresas.IDRegimenFiscal,0) as IDRegimenFiscal        
		,COALESCE(RegimenesFiscales.Codigo,'') as CodigoRegimenFiscal        
		,COALESCE(RegimenesFiscales.Descripcion,'') as RegimenFiscal        
		,ISNULL(Empresas.IDOrigenRecurso,0) as IDOrigenRecurso        
		,COALESCE(OrigenesRecursos.Codigo,'') as CodigoOrigenRecurso        
		,COALESCE(OrigenesRecursos.Descripcion,'') as OrigenRecurso   
		,COALESCE(Empresas.CURP,'') as CURPEmpresa  
		, CASE WHEN ISNULL(emp.DomicilioFiscal,'') <> '' THEN emp.DomicilioFiscal
			ELSE isnull((Select Top 1 ISNULL(cp.CodigoPostal, dir.CodigoPostal) from RH.tblDireccionEmpleado dir with(nolock)
				   left join Sat.tblCatCodigosPostales cp with(nolock)
					on dir.IDCodigoPostal = cp.IDCodigoPostal
					where dir.IDEmpleado = Empleado.IDEmpleado
					order by dir.FechaFin desc),'')
				END AS DomicilioFiscalReceptor
		,  CASE WHEN ISNULL(RegimenesFiscalesReceptor.Codigo,'') = '' THEN '605'
			ELSE ISNULL(RegimenesFiscalesReceptor.Codigo,'')
			END as CodigoRegimenFiscalReceptor
        ,COALESCE(isnull(TipoContrato.Codigo,'01'),'') as CodigoTipoContrato  ------------------------      
		,COALESCE(isnull(TipoContrato.Descripcion,'01'),'') as TipoContrato -------------------------        
  
		,ISNULL(Historial.IDArea,0) as IDArea        
		,COALESCE(Areas.Codigo,'')+' '+COALESCE(Areas.Descripcion,'') as Area        
		,ISNULL(Historial.IDDivision,0) as IDDivision        
		,COALESCE(Divisiones.Codigo,'')+' '+COALESCE(Divisiones.Descripcion,'') as Division        
		,ISNULL(Historial.IDClasificacionCorporativa,0) as IDClasificacionCorporativa        
		--,COALESCE(clasificaciones.Codigo,'')+' '+COALESCE(clasificaciones.Descripcion,'') as ClasificacionCorporativa        		
		, COALESCE(clasificaciones.Codigo, '') + ' ' + COALESCE(ISNULL(JSON_VALUE(clasificaciones.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Descripcion')), ''), '') as ClasificacionCorporativa
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
		,RBTimbrado.NombreReporte  as PathRecibo
		,RBNoTimbrado.NombreReporte  as PathReciboNominaNoTimbrado
		,Facturacion.fnCoreGetCustomID(Historial.IDHistorialEmpleadoPeriodo  ) CustomID
	From Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)    
		--join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = Historial.IDEmpleado and dfe.IDUsuario = @IDUsuario   
		Inner join Nomina.tblCatPeriodos Periodos  with (nolock) on Historial.IDPeriodo = Periodos.IDPeriodo        
		Inner join Nomina.tblCatTipoNomina TipoNomina  with (nolock) on TipoNomina.IDTipoNomina = Periodos.IDTipoNomina        
		Inner join Sat.tblCatPeriodicidadesPago Periodicidad with (nolock) on Periodicidad.IDPeriodicidadPago = TipoNomina.IDPeriodicidadPago        
		--Inner join RH.tblEmpleados Empleado on Historial.IDEmpleado = Empleado.IDEmpleado        
		Inner join RH.tblEmpleadosMaster Empleado  with (nolock) on Historial.IDEmpleado = Empleado.IDEmpleado
		left join RH.tblEmpleados emp with(nolock) on Empleado.IDEmpleado = emp.IDEmpleado
		Left Join Sat.tblCatRegimenesFiscales RegimenesFiscalesReceptor with (nolock) on RegimenesFiscalesReceptor.IDRegimenFiscal = emp.IDRegimenFiscal     
		Left Join Sat.tblCatMunicipios Municipios  with (nolock) on Empleado.IDMunicipioNacimiento = Municipios.IDMunicipio         
		Left Join Sat.tblCatEstados Estados   with (nolock) on Empleado.IDEstadoNacimiento = Estados.IDEstado        
		Left Join Sat.tblCatPaises Paises  with (nolock) on Empleado.IDPaisNacimiento = Paises.IDPais        
		Left Join Sat.tblCatTiposJornada jornada with (nolock) on Empleado.IDJornadaLaboral = Jornada.IDTipoJornada  
		left join Nomina.tblControlLayoutDispersionEmpleado clde with(nolock)
			on clde.IDPeriodo = Historial.IDPeriodo
			and clde.IDEmpleado = Historial.IDEmpleado
			and clde.IDLayoutPago in (select IDLayoutPago from #tempLayouts)
		
		--Left Join RH.tblPagoEmpleado Pago on Empleado.IDEmpleado = Pago.IDEmpleado        
		--Left Join Nomina.tblLayoutPago Layout on Pago.IDLayoutPago = Layout.IDLayoutPago        
		Left Join Sat.tblCatBancos Bancos on Bancos.IDBanco = clde.IDBanco        
		Left join RH.tblCatCentroCosto CentroCosto with (nolock) on Historial.IDCentroCosto = CentroCosto.IDCentroCosto        
		Left Join RH.tblCatDepartamentos Departamentos with (nolock) on Historial.IDDepartamento = Departamentos.IDDepartamento        
		Left Join RH.tblCatSucursales Sucursales  with (nolock) on Historial.IDSucursal = Sucursales.IDSucursal        
		Left Join RH.tblCatPuestos Puestos with (nolock) on Historial.IDPuesto = Puestos.IDPuesto        
		Left Join RH.TblCatRegPatronal RegPatronal  with (nolock) on Historial.IDRegPatronal = RegPatronal.IDRegPatronal        
		Left Join Sat.tblCatRiesgosPuesto Riesgos  with (nolock) on Riesgos.IDRiesgoPuesto = RegPatronal.IDClaseRiesgo
		left join IMSS.tblCatClaseRiesgo ImssRiesgo with (nolock) on ImssRiesgo.IDClaseRiesgo = RegPatronal.IDClaseRiesgo
		Left Join RH.tblCatClientes Clientes with (nolock) on Historial.IDCliente = Clientes.IDCliente        
		Left Join RH.tblEmpresa Empresas with (nolock) on Historial.IDEmpresa = Empresas.IDEmpresa        
		Left Join Sat.tblCatCodigosPostales CP with (nolock) on CP.IDCodigoPostal = Empresas.IDCodigoPostal        
		Left Join Sat.tblCatEstados Estado  with (nolock) on Empresas.IDEstado = Estado.IDEstado        
		Left Join Sat.tblCatRegimenesFiscales RegimenesFiscales   with (nolock) on RegimenesFiscales.IDRegimenFiscal = Empresas.IDRegimenFiscal        
		Left Join Sat.tblCatOrigenesRecursos OrigenesRecursos with (nolock) on OrigenesRecursos.IDOrigenRecurso = Empresas.IDOrigenRecurso  
		left join Sat.tblCatTiposContrato TipoContrato with (nolock) on Empleado.IDTipoContrato = TipoContrato.IDTipoContrato----------------------------     
		Left Join RH.tblCatArea Areas   with (nolock) on Historial.IDArea = Areas.IDArea        
		Left join RH.tblCatDivisiones Divisiones with (nolock) on Historial.IDDivision = Divisiones.IDDivision        
		Left Join RH.tblCatClasificacionesCorporativas clasificaciones with (nolock) on Historial.IDclasificacionCorporativa = Clasificaciones.IDClasificacionCorporativa        
		Left Join RH.tblCatRegiones Regiones  with (nolock) on Historial.IDRegion = Regiones.IDRegion        
		Left Join RH.tblCatRazonesSociales RS with (nolock) on Historial.IDRazonSocial = RS.IDRazonSocial        
		Left Join Facturacion.tblTimbrado Timbrado  with (nolock) on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo and timbrado.Actual = 1        
		LEFT join Facturacion.tblCatEstatusTimbrado Estatustimbrado with (nolock) on Timbrado.IDEstatusTimbrado = Estatustimbrado.IDEstatusTimbrado        
		LEFT JOIN Sat.tblCatTiposRegimen TiposRegimen   with (nolock) on Timbrado.IDTipoRegimen = TiposRegimen.IDTipoRegimen         
		LEFT Join Seguridad.tblUsuarios Usuarios  with (nolock) on Timbrado.IDUsuario = Usuarios.IDUsuario         
		LEFT JOIN #tempMovAfil MOV  with (nolock) ON Historial.IDEmpleado = MOV.IDEmpleado        
		left join Reportes.tblCatReportesBasicos RBTimbrado 
			on RBTimbrado.IDReporteBasico = COALESCE(JSON_VALUE(Clientes.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'IDReporteNominaTimbrado')),'') 
		 left join Reportes.tblCatReportesBasicos RBNoTimbrado 
			on RBNoTimbrado.IDReporteBasico = COALESCE(JSON_VALUE(Clientes.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'IDReporteNominaNoTimbrado')),'')
	WHERE  ((@Timbrado = 0 and isnull(Estatustimbrado.Descripcion,'NUEVO') in ('NUEVO','CANCELADO','ERROR')         
	   OR   (@Timbrado = 1 and Estatustimbrado.Descripcion in ('TIMBRADO')))         
	  AND Historial.IDPeriodo = @IDPeriodo)        
	  AND Historial.IDHistorialEmpleadoPeriodo = @Folio
END
GO
