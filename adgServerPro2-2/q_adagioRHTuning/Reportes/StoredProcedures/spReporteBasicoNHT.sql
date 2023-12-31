USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoNHT](    
	 @ClaveEmpleadoInicial VARCHAR(max), 
     @FechaIni Date
) as    
	SET FMTONLY OFF 

DECLARE
@IDEmpleado int,
@Fecha date=GETDATE(),
@Ejercicio INT

if object_id('tempdb..#tempMovAfil') is not null    
    drop table #tempMovAfil   

SELECT @IDEmpleado=IDEmpleado FROM RH.tblEmpleados WHERE ClaveEmpleado=@ClaveEmpleadoInicial

Select @Ejercicio = DATEPART(YEAR,GETDATE())

select IDEmpleado, FechaAlta, FechaBaja,            
      case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso            
      ,IDMovAfiliatorio    
	into #tempMovAfil            
	from (select distinct tm.IDEmpleado,            
        case when(IDEmpleado is not null) then (select top 1 Fecha             
                 from [IMSS].[tblMovAfiliatorios]  mAlta WITH(NOLOCK)            
                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento            
                 where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'              
                 Order By mAlta.Fecha Desc , c.Prioridad DESC ) end as FechaAlta,            
        case when (IDEmpleado is not null) then (select top 1 Fecha             
                 from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)            
                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento            
                 where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'              
                and mBaja.Fecha <= @Fecha             
			order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,            
        case when (IDEmpleado is not null) then (select top 1 Fecha             
                 from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)            
                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento            
                 where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'              
                and mReingreso.Fecha <= @Fecha             
                order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso              
        ,(Select top 1 mSalario.IDMovAfiliatorio from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
                 where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')             
                 order by mSalario.Fecha desc ) as IDMovAfiliatorio                                             
	from [IMSS].[tblMovAfiliatorios] tm   WITH(NOLOCK)) mm    
	where mm.IDEmpleado = @IDEmpleado





SELECT 
 E.*
,M.*
,CONCAT(E.Paterno,
        CASE WHEN E.Materno IS NOT NULL THEN ' ' ELSE '' END,
                                  COALESCE(E.Materno,'')) as surname
,CONCAT(E.Nombre,
        CASE WHEN E.SegundoNombre IS NOT NULL THEN ' ' ELSE '' END,
                            COALESCE(E.SegundoNombre,'')) as christianNames
 ---DIRECCION
 ,UPPER(Isnull(DireccionEmpleado.Calle,'')) as DireccionEmpleadoCalle
	   ,UPPER(Isnull(DireccionEmpleado.Exterior,'')) as DireccionEmpleadoExterior
	   ,UPPER(Isnull(DireccionEmpleado.Interior,'')) as DireccionEmpleadoInterior
	   ,UPPER(Isnull(CP.CodigoPostal,DireccionEmpleado.CodigoPostal)) as DireccionEmpleadoCodigoPostal
	   ,UPPER(Isnull(Colonias.NombreAsentamiento,DireccionEmpleado.Colonia)) as DireccionEmpleadoColonia
	   ,UPPER(Isnull(Municipios.Descripcion,DireccionEmpleado.Municipio)) as DireccionEmpleadoMunicipio
	   ,UPPER(Isnull(Estados.NombreEstado,DireccionEmpleado.Estado)) as DireccionEmpleadoEstado
	   ,UPPER(Isnull(Localidades.Descripcion,DireccionEmpleado.Localidad)) as DireccionEmpleadoLocalidad 
	   ,UPPER(Isnull(DireccionEmpleadoPais.Descripcion,DireccionEmpleadoPais.Descripcion)) as DireccionEmpleadoPais  
       ,CONCAT(UPPER(Isnull(DireccionEmpleado.Calle,'')),' ',UPPER(Isnull(Municipios.Descripcion,DireccionEmpleado.Municipio))) AS ADDRESS
       ,FORMAT(M.FechaBaja,'MM/dd/yyyy','en') as DateOfLeaving
       ,DATEDIFF(WEEK,CONCAT('01-01-',@Ejercicio),M.FechaBaja) as NoOfWeeks
       ,DATEDIFF(MONTH,CONCAT('01-01-',@Ejercicio),M.FechaBaja) as NoOfMonths
       ,(Select SUM(ImporteTotal1) from nomina.tblCatConceptos cc
                              JOIN nomina.tblDetallePeriodo dp On dp.IDConcepto = cc.IDConcepto
                              JOIN nomina.tblCatPeriodos cp ON cp.IDPeriodo = dp.IDPeriodo
                              Where IDEmpleado = @IDEmpleado and cc.Descripcion = 'GROSS PAY'  and Ejercicio = @Ejercicio) as GrossPay
        ,(Select SUM(ImporteTotal1) from nomina.tblCatConceptos cc
                              JOIN nomina.tblDetallePeriodo dp On dp.IDConcepto = cc.IDConcepto
                              JOIN nomina.tblCatPeriodos cp ON cp.IDPeriodo = dp.IDPeriodo
                              Where IDEmpleado = @IDEmpleado and cc.Descripcion = 'NIS'  and Ejercicio = @Ejercicio) as NISToDate
        ,(Select SUM(ImporteTotal1) from nomina.tblCatConceptos cc
                              JOIN nomina.tblDetallePeriodo dp On dp.IDConcepto = cc.IDConcepto
                              JOIN nomina.tblCatPeriodos cp ON cp.IDPeriodo = dp.IDPeriodo
                              Where IDEmpleado = @IDEmpleado and cc.Descripcion = 'PAYE'  and Ejercicio = @Ejercicio) as TaxToDate

        ,FORMAT (E.FechaAntiguedad, 'MMMM','en') as DateMonthSince
        ,FORMAT (E.FechaAntiguedad, 'yyyy','en') as DateYearSince
        ,FORMAT (E.FechaAntiguedad, 'dd','en') as DateDaySince
        ,CASE
            WHEN FORMAT (E.FechaAntiguedad, 'dd','en') IN (1,21,31) THEN 'st'
            WHEN FORMAT (E.FechaAntiguedad, 'dd','en') IN (2,22) THEN 'nd'
            WHEN FORMAT (E.FechaAntiguedad, 'dd','en') IN (3,23) THEN 'rd'
            ELSE 'th'
            END AS ORDINALSince
        
        ,FORMAT (@FechaIni, 'MMMM','en') as DateMonthDoc
        ,FORMAT (@FechaIni, 'yyyy','en') as DateYearDoc
        ,FORMAT (@FechaIni, 'dd','en') as DateDayDoc

        ,CASE
            WHEN FORMAT (@FechaIni, 'dd','en') IN (1,21,31) THEN 'st'
            WHEN FORMAT (@FechaIni, 'dd','en') IN (2,22) THEN 'nd'
            WHEN FORMAT (@FechaIni, 'dd','en') IN (3,23) THEN 'rd'
            ELSE 'th'
            END AS ORDINALDoc
        ,Case when (E.Sexo = 'MASCULINO' ) then 'Mr.'
         When (e.Sexo = 'FEMENINO') then 'Ms.'
         end as Tittle

        ,Utilerias.InitialCap(Utilerias.MoneyToWords_en(E.SalarioDiario*20)) as MonthlyIncome
        ,Utilerias.InitialCap(E.Nombre) AS NombreC         
		,Utilerias.InitialCap(E.SegundoNombre) AS SegundoNombreC           
		,Utilerias.InitialCap(E.Paterno) AS PaternoC          
		,Utilerias.InitialCap(E.Materno) AS MaternoC 
        ,Utilerias.InitialCap(isnull(EMP.NombreComercial,'')) as EmpresaC  
        ,Utilerias.InitialCap(isnull(E.Puesto,'')) as PuestoC  
        ,Utilerias.InitialCap(Utilerias.MoneyToWords_en(E.SalarioDiario*240)) as YearlyIncome
        ,FORMAT(E.SalarioDiario*240, 'C') as YearlyIncomeNum

FROM rh.tblEmpleadosMaster E
left join #tempMovAfil M
			on E.IDEmpleado = E.IDEmpleado
		LEFT JOIN [IMSS].[tblMovAfiliatorios] MOV WITH(NOLOCK)          
			ON M.IDMovAfiliatorio = MOV.IDMovAfiliatorio 
		LEFT JOIN [IMSS].[tblCatRazonesMovAfiliatorios]	MovRaz
			on MOV.IDRazonMovimiento = MovRaz.IDRazonMovimiento
	LEFT JOIN [IMSS].[tblMovAfiliatorios] MOVBaja WITH(NOLOCK)          
		ON M.IDEmpleado = MOVBaja.IDEmpleado 
		and m.FechaBaja = MOVBaja.Fecha
	LEFT JOIN [IMSS].[tblCatRazonesMovAfiliatorios]	MovRazBaja
		on MOVBaja.IDRazonMovimiento = MovRazBaja.IDRazonMovimiento
    left join [RH].[tblDireccionEmpleado] DireccionEmpleado WITH(NOLOCK)   
			on e.IDEmpleado = DireccionEmpleado.IDEmpleado  
				AND DireccionEmpleado.FechaIni<= @Fecha and DireccionEmpleado.FechaFin >= @Fecha
		Left join Sat.tblCatCodigosPostales CP WITH(NOLOCK)   
			on CP.IDCodigoPostal = DireccionEmpleado.IDCodigoPostal
		Left join Sat.tblCatEstados Estados WITH(NOLOCK)   
			on DireccionEmpleado.IDEstado = Estados.IDEstado
		Left join Sat.tblCatMunicipios Municipios WITH(NOLOCK)   
			on DireccionEmpleado.IDMunicipio = Municipios.IDMunicipio
		Left join Sat.tblCatColonias Colonias WITH(NOLOCK)   
			on DireccionEmpleado.IDColonia = Colonias.IDColonia
		Left join Sat.tblCatPaises DireccionEmpleadoPais 
			on DireccionEmpleado.IDPais = DireccionEmpleadoPais.IDPais
		Left join Sat.tblCatLocalidades Localidades WITH(NOLOCK)   
			on DireccionEmpleado.IDLocalidad = Localidades.IDLocalidad
            LEFT JOIN [RH].[tblEmpresa] EMP WITH(NOLOCK)          
			ON EMP.IdEmpresa = e.IDEmpresa 

where ClaveEmpleado = @ClaveEmpleadoInicial


GO
