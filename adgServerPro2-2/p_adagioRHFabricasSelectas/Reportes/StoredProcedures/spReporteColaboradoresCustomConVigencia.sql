USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
- Código de empleado
- Nombre del empleado
- Departamento
- Puesto
- Fecha de ingreso
- Fecha de baja
- Días vigentes
- Salario Diario
- Salario Diario Integrado
Que se pueda filtrar por fecha y número de registro patronal"
*/

CREATE PROCEDURE [Reportes].[spReporteColaboradoresCustomConVigencia](

	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT

)
AS

BEGIN

	SET NOCOUNT ON;

	DECLARE 
		 @FechaIni DATE
		,@FechaFin DATE
		,@IDRegPatronal INT
		,@Empleados [RH].[dtEmpleados]
		,@Fechas [App].[dtFechas]
		,@Filtros [Nomina].[dtFiltrosRH] 
		,@RegPatronal VARCHAR(255)
		,@Periodo VARCHAR(255)


	SELECT @FechaIni	  = ISNULL((SELECT TOP 1 CAST(Item AS DATE) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaIni'),',')),'1900-01-01')
	SELECT @FechaFin	  = ISNULL((SELECT TOP 1 CAST(Item AS DATE) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaFin'),',')),'9999-12-31')
	SELECT @IDRegPatronal = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'RegPatronales'),',')),0)
	SELECT @RegPatronal   = RegistroPatronal+' - '+RazonSocial FROM RH.tblCatRegPatronal WHERE IDRegPatronal = @IDRegPatronal


	SET @Periodo = 'DEL '+CAST(FORMAT(@FechaIni,'dd/MM/yyyy') AS VARCHAR(10))+' AL '+CAST(FORMAT(@FechaFin,'dd/MM/yyyy') AS VARCHAR(10))


	IF (@IDRegPatronal = 0)
	BEGIN
		RAISERROR('SELECCIONE UN REGISTRO PATRONAL',16,1)
		RETURN;
	END


	INSERT INTO @Empleados
	EXEC [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @Filtros, @IDUsuario = @IDUsuario


	INSERT INTO @Fechas 
	EXEC App.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin


	IF OBJECT_ID('TempDB..#TempVigenciaEmpleados') IS NOT NULL DROP TABLE #TempVigenciaEmpleados;
	IF OBJECT_ID('TempDB..#TempMovAfil') IS NOT NULL DROP TABLE #TempMovAfil;
  
	CREATE TABLE #TempVigenciaEmpleados 
	(  
		IDEmpleado INT NULL,  
		Fecha DATE NULL,  
		Vigente BIT NULL  
	);


	INSERT INTO #TempVigenciaEmpleados (IDEmpleado, Fecha, Vigente)
	EXEC [RH].[spBuscarListaFechasVigenciaEmpleado] @dtEmpleados = @Empleados, @Fechas = @Fechas, @IDUsuario = @IDUsuario

	DELETE #TempVigenciaEmpleados WHERE Vigente = 0


	SELECT 
		 IDEmpleado
		,FechaAlta
		,FechaBaja           
		,CASE WHEN ((FechaBaja IS NOT NULL AND FechaReingreso IS NOT NULL) AND FechaReingreso > FechaBaja) THEN FechaReingreso ELSE NULL END AS FechaReingreso            
		,FechaReingresoAntiguedad
		,IDMovAfiliatorio    
	INTO #TempMovAfil            
	FROM (
			SELECT 
			DISTINCT tm.IDEmpleado,            
					CASE WHEN(IDEmpleado is not null) 
					THEN (
															select top 1 Fecha             
	    														   from [IMSS].[tblMovAfiliatorios]  mAlta WITH(NOLOCK)            
	    														   join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) 
																		 on mAlta.IDTipoMovimiento=c.IDTipoMovimiento            
	    														   where mAlta.IDEmpleado=tm.IDEmpleado 
																		and c.Codigo='A'              
	    														   Order By mAlta.Fecha Desc , c.Prioridad DESC 
					) END AS FechaAlta,            
					CASE WHEN (IDEmpleado is not null) 
					THEN (
															select top 1 Fecha             
	    														   from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)            
	    														   join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) 
																		on mBaja.IDTipoMovimiento=c.IDTipoMovimiento            
	    														   where mBaja.IDEmpleado=tm.IDEmpleado 
																		and c.Codigo='B'              
	    																and mBaja.Fecha <= @FechaFin             
																   order by mBaja.Fecha desc, C.Prioridad desc
					) END AS FechaBaja,            
					CASE WHEN (IDEmpleado is not null) 
					THEN (
															select top 1 Fecha             
	    															from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)            
	    															join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) 
																		on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento            
	    															where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'              
	    																  and mReingreso.Fecha <= @FechaFin 
	    																  and isnull(mReingreso.RespetarAntiguedad,0) <> 1              
	    															order by mReingreso.Fecha desc, C.Prioridad desc
					) END AS FechaReingreso,
					CASE WHEN (IDEmpleado is not null) 
					THEN (
															select top 1 Fecha             
	    														   from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)            
	    														   join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) 
																	   on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento            
	    														   where mReingreso.IDEmpleado=tm.IDEmpleado 
																		 and c.Codigo='R'
	    																 and mReingreso.Fecha <= @FechaFin 
	    																 and isnull(mReingreso.RespetarAntiguedad,0) <> 1              
																   order by mReingreso.Fecha desc, C.Prioridad desc
					)END AS FechaReingresoAntiguedad,
					(
															Select top 1 mSalario.IDMovAfiliatorio 
																   from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
	    														   join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) 
																		on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
	    		                                        		   where mSalario.IDEmpleado=tm.IDEmpleado 
																		 and c.Codigo in ('A','M','R')      
	    		                                        				 and mSalario.Fecha <= @FechaFin          
	    		                                        		  order by mSalario.Fecha desc 
					)  IDMovAfiliatorio                                             
			from [IMSS].[tblMovAfiliatorios]  tm 
			WHERE TM.IDEmpleado IN (SELECT IDEmpleado FROM @Empleados)
		) mm     


	SELECT 
		 E.ClaveEmpleado AS Clave
		,E.NOMBRECOMPLETO AS Nombre
		,E.Departamento AS Departamento
		,E.Puesto AS Puesto
		,CASE WHEN TM.FechaReingreso IS NOT NULL THEN FORMAT(TM.FechaReingreso,'dd/MM/yyyy') ELSE FORMAT(TM.FechaAlta,'dd/MM/yyyy') END AS [Fecha Ingreso]
		,FORMAT(TM.FechaBaja,'dd/MM/yyyy') AS [Fecha Baja]
		,(SELECT COUNT(*) FROM #TempVigenciaEmpleados WHERE IDEmpleado = E.IDEmpleado) AS [Dias Vigencia]
		,TM.SalarioDiario AS [Salario Diario]
		,TM.SalarioIntegrado AS [Salario Integrado]
		,@RegPatronal AS [Registro Patronal]
		,@Periodo AS [Periodo De Consulta]
	FROM @Empleados E
		INNER JOIN (
					 SELECT TMA.*, MOV.SalarioDiario, MOV.SalarioIntegrado, MOV.IDRegPatronal
					 FROM #TempMovAfil TMA
						LEFT JOIN IMSS.tblMovAfiliatorios MOV
					 		ON TMA.IDMovAfiliatorio = Mov.IDMovAfiliatorio
					 WHERE (MOV.IDRegPatronal = (SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'RegPatronales'),',')))
				   ) TM ON E.IDEmpleado = TM.IDEmpleado
	ORDER BY E.ClaveEmpleado ASC


END
GO
