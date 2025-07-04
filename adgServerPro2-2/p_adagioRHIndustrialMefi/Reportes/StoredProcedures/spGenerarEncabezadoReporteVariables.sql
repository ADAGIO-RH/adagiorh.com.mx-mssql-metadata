USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Reportes.spGenerarEncabezadoReporteVariables 
(
	@Ejercicio int,
	@IDBimestre int,
	@EmpleadoIni Varchar(20) = '0',              
	@EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ', 
	@dtDepartamentos Varchar(max) = '',
	@dtSucursales Varchar(max) = '',
	@dtPuestos Varchar(max) = '',
	@dtClasificacionesCorporativas Varchar(max) = '',
	@dtRegPatronales Varchar(max) = '',
	@dtDivisiones Varchar(max) = '',
	@Aplicar bit
)
AS
BEGIN

 SET FMTONLY OFF;
DECLARE @dtEmpleadosVigentes RH.dtEmpleados,
		@dtEmpleadosTrabajables RH.dtEmpleados,
		@FechaIni Date = getdate(),
		@Fechafin Date = getdate(),
		@SalarioMinimo decimal(18,2),
		@UMA Decimal(18,2),
		@fechaInicioBimestre date,
		@fechaFinBimestre date,
		@diasBimestre int,
		@DescripcionBimestre Varchar(MAX)


		select @fechaInicioBimestre = min(DATEADD(month,IDMes-1,DATEADD(year,@Ejercicio-1900,0))) 
			   , @fechaFinBimestre=MAX(DATEADD(day,-1,DATEADD(month,IDMes,DATEADD(year,@Ejercicio-1900,0)))) 
		from Nomina.tblCatMeses
		where cast(IDMes as varchar) in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres where IDBimestre = @IDBimestre),','))
	
		select @DescripcionBimestre = Descripcion from Nomina.tblCatBimestres where IDBimestre = @IDBimestre

		set @diasBimestre = DATEDIFF(DAY, @fechaInicioBimestre, @fechaFinBimestre)


		set @EmpleadoIni = case when @EmpleadoIni = '' then '0' else @EmpleadoIni end
		set @EmpleadoFin = case when @EmpleadoFin = '' then 'ZZZZZZZZZZZZZZZZZZ' else @EmpleadoFin end

		select top 1 @SalarioMinimo = SalarioMinimo,
					@UMA = UMA 
		from Nomina.tblSalariosMinimos
		where Year(Fecha) = @Ejercicio
		order by Fecha desc


		select @DescripcionBimestre Bimestre,
			@Ejercicio as Ejercicio
			,@SalarioMinimo as SalarioMinimo
			,@UMA as UMA
			,CriterioDias = CASE WHEN CriterioDias = 0 THEN 'DIAS ACUMULADOS DEL TRABAJADOR' else 'DIAS DEL BIMESTRE' END
		 ,SUBSTRING(
        (
            SELECT ','+c.Codigo+' - '+c.Descripcion  AS [text()]
            FROM Nomina.tblcatconceptos c
			cross apply Nomina.tblConfigReporteVariablesBimestrales vb
            where IDConcepto in (select item from app.Split(vb.ConceptosIntegrablesVariables,','))
            FOR XML PATH ('')
        ), 2, 1000) [ConceptosIntegran]
		 ,DATEADD(Day,1,@fechaFinBimestre) as DiaAplicacion
		from Nomina.tblConfigReporteVariablesBimestrales


END
GO
