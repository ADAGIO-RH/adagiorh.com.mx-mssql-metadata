USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [Intranet].[spDetalleNominaGrafica]
	@IDEmpleado int
	,@Ejercicio int
as 
BEGIN

	DECLARE 
		@QueryPercepciones NVarchar(MAX),
		@QueryDeducciones NVarchar(MAX),
		@QueryTotalPagado NVarchar(MAX),
		@IDPais int,
		@ID_PAIS_MEXICO int = 151
	;

	DECLARE @IDsConceptosPercepciones as Table(
		IDConcepto int
	);
	DECLARE @IDsConceptosDeducciones as Table(
		IDConcepto int
	);
	DECLARE	@IDsConceptosTotalPagados as Table(
		IDConcepto int
	);

	Select top 1 @IDPais = TN.IDPais
	from RH.tblEmpleadosMaster M with(nolock)
		inner join Nomina.tblCatTipoNomina TN with(nolock)
			on TN.IDTipoNomina = m.IDTipoNomina
	where IDEmpleado = @IDEmpleado

	SELECT @QueryPercepciones = Filtro 
	FROM Intranet.tblConfigDashboardNomina with(nolock)
	WHERE isnull(IDPais, @ID_PAIS_MEXICO) = @IDPais
		and BotonLabel in ( 'Percepciones', 'TOTAL INGRESOS')

	SELECT @QueryDeducciones = Filtro 
	FROM Intranet.tblConfigDashboardNomina with(nolock)
	WHERE isnull(IDPais, @ID_PAIS_MEXICO) = @IDPais
		and BotonLabel in ( 'Deducciones')

	SELECT @QueryTotalPagado = Filtro 
	FROM Intranet.tblConfigDashboardNomina with(nolock)
	WHERE isnull(IDPais, @ID_PAIS_MEXICO) = @IDPais
		and BotonLabel in ( 'Total Pagado')

	INSERT INTO @IDsConceptosPercepciones
	EXEC sp_executesql @QueryPercepciones

	INSERT INTO @IDsConceptosDeducciones
	EXEC sp_executesql @QueryDeducciones

	INSERT INTO @IDsConceptosTotalPagados
	EXEC sp_executesql @QueryTotalPagado

	;with  
		TOTALPERCEPCIONES as (
			Select 
				M.IDMes as [Order]
				,P.Descripcion as PeriodoNomina
				,DP.ImporteTotal1 as  TotalPercepciones
				,P.ClavePeriodo
				,DP.IDEmpleado
	
			from Nomina.tblCatMeses m with (nolock)
				left join Nomina.tblCatPeriodos P with (nolock)
					on m.IDMes = p.IDMes AND P.Ejercicio = @Ejercicio and P.Cerrado = 1  
				left join Nomina.tblDetallePeriodo DP with (nolock)	on DP.IDPeriodo = P.IDPeriodo 
				and DP.IDEmpleado = @IDEmpleado 
				join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto 
					and c.IDConcepto in (Select IDConcepto from @IDsConceptosPercepciones) 		 	 

		), 
		TOTALPAGADO as (
			Select 
				M.IDMes as [Order]
				,P.Descripcion as PeriodoNomina
				,DP.ImporteTotal1 as  TotalPagado
				,P.ClavePeriodo
				,DP.IDEmpleado
			from Nomina.tblCatMeses m with (nolock)
				left join Nomina.tblCatPeriodos P with (nolock)
					on m.IDMes = p.IDMes AND P.Ejercicio = @Ejercicio and P.Cerrado = 1  
				left join Nomina.tblDetallePeriodo DP with (nolock)	on DP.IDPeriodo = P.IDPeriodo 
				and DP.IDEmpleado = @IDEmpleado
				join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto 
					and c.IDConcepto in (Select IDConcepto from @IDsConceptosTotalPagados)--c.IDTipoConcepto = 5
		), 
		TOTALDEDUCCIONES as (
			Select 
				M.IDMes as [Order]
				,P.Descripcion as PeriodoNomina
				,DP.ImporteTotal1 as  TotalDeducciones
				,P.ClavePeriodo
				,DP.IDEmpleado
			from Nomina.tblCatMeses m with (nolock)
				left join Nomina.tblCatPeriodos P with (nolock)
					on m.IDMes = p.IDMes AND P.Ejercicio = @Ejercicio and P.Cerrado = 1  
				left join Nomina.tblDetallePeriodo DP with (nolock)	on DP.IDPeriodo = P.IDPeriodo 
					and DP.IDEmpleado = @IDEmpleado
				join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto 
					and c.IDConcepto in (Select IDConcepto from @IDsConceptosDeducciones)--c.Codigo = '560' 	
		)	

		select         
			isnull(SUM(TP.TotalPercepciones),0) as TotalPercepciones, 
			isnull(SUM(TPA.TotalPagado),0) as TotalPagado,
			isnull(SUM(TD.TotalDeducciones),0) as TotalDeducciones	
		from TOTALPERCEPCIONES TP
			left join TOTALPAGADO TPA on TPA.ClavePeriodo = TP.ClavePeriodo
			left join TOTALDEDUCCIONES TD on TD.ClavePeriodo = TP.ClavePeriodo
END
GO
