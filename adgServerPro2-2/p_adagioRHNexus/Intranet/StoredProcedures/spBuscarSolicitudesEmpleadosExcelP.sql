USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Intranet].[spBuscarSolicitudesEmpleadosExcelP](
    @dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int

)
AS
BEGIN
/*
declare @p2 Nomina.dtFiltrosRH
insert into @p2 values(N'Empleados',N'240')
insert into @p2 values(N'FechaIni',N'2021-11-25')
insert into @p2 values(N'FechaFin',N'2021-11-25')
insert into @p2 values(N'IDUsuario',N'1')*/

    Declare 
	@Empleados  varchar(max) = null,
	@FechaIni varchar(max) = null,
	@FechaFin varchar(max)= null,
	@Counter INT = 0,
	@IDEmpleado INT,
	@IDIncidenciaTomada VARCHAR(5),
	@IncTomadas int,
	@FechaIniVenc varchar(max) = null,
	@FechaFinVenc varchar(max)= null
	;
	
     
	SET @FechaIni = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')),convert(varchar, getdate(), 23))
    SET @FechaFin = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')),convert(varchar, getdate(), 23))
    SET @Empleados = isnull((Select top 1 cast(item as Varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),',')),'0')

	--IF object_ID('TEMPDB..#TempTomados') IS NOT NULL DROP TABLE #TempTomados 

	--DECLARE @tempResponse AS TABLE (
	--		ID INT IDENTITY(1,1),
	--		IDEmpleado int,
	--		IDIncidenciaSaldo INT,
	--		IDIncidencia VARCHAR(10),
	--		FechaInicio DATE,
	--		FechaFin DATE,
	--		FechaRegistro DATETIME,
	--		Cantidad INT,
	--		IncTomadas INT,
	--		IncVencidas INT,
	--		IncDisponibles INT
	--	);

	--	INSERT @tempResponse
	--	SELECT   
	--		S.IDEmpleado,
	--		S.IDIncidenciaSaldo,
	--		S.IDIncidencia,
	--		S.FechaInicio,
	--		S.FechaFin,
	--		S.FechaRegistro,
	--		S.Cantidad,
	--		0 AS IncTomadas,
	--		0 AS IncVencidas,
	--		0 AS IncDisponibles
	--	FROM [Asistencia].[tblIncidenciasSaldos] S WITH (NOLOCK)
	--		INNER JOIN [Asistencia].[tblCatIncidencias] I WITH (NOLOCK) ON S.IDIncidencia = I.IDIncidencia
	--	--WHERE  S.FechaInicio <= @FechaFin and S.FechaFin >= @FechaFin


	--	WHILE(@Counter <= (SELECT COUNT(ID) FROM @tempResponse))
	--	BEGIN
	--		SELECT 
	--			@IDEmpleado = Idempleado,
	--			@IDIncidenciaTomada = IDIncidencia, 
	--			@FechaIniVenc = FechaInicio, 
	--			@FechaFinVenc = FechaFin 
	--		FROM @tempResponse 
	--		WHERE ID = @Counter;
				
	--		SET @IncTomadas = [Asistencia].[fnBuscarIncidenciasEmpleado](@IDEmpleado, @IDIncidenciaTomada, @FechaIniVenc, @FechaFinVenc);
				
	--		UPDATE @tempResponse  
	--			SET IncTomadas = @IncTomadas,
	--				IncVencidas = CASE WHEN ((DATEDIFF(DAY, @FechaFin, @FechaFinVenc )) < 0) THEN Cantidad - @IncTomadas ELSE 0 END,
	--				IncDisponibles = CASE WHEN ((DATEDIFF(DAY, @FechaFin, @FechaFinVenc  )) >= 0) then Cantidad - @IncTomadas ELSE 0 END
	--		WHERE ID = @Counter;

	--		SET @Counter = @Counter + 1
	--	END	

	--	select Idempleado, IDincidencia, Cantidad, IncTomadas, IncVencidas, IncDisponibles
	--	into #TempTomados
	--	from @tempResponse
	
	declare @FechaAutoriza table 
		 ( ID int NOT NULL identity (1,1) 
		  ,Folio int
		  ,Aprobada varchar(100)
		  ,FechaAutoriza varchar(100)
		 )


	INSERT INTO @FechaAutoriza
	SELECT
		isnull(REPLACE(JSON_VALUE(Parametros, '$.Folio'),'S',''),'')  AS [Folio],
		isnull(JSON_VALUE(Parametros, '$.Mensaje'),'') AS [Aprobada],
		isnull( CONVERT(varchar,JSON_VALUE(Parametros, '$.Fecha'),23),'9999-12-31') AS [FechaAutoriza]
	FROM app.tblNotificaciones	WHERE ISJSON(Parametros) > 0 
		and  JSON_VALUE(Parametros, '$.Mensaje') like ('%APROBADA%')-- OR  JSON_VALUE(Parametros, '$.Mensaje') LIKE  ('%APPROVED%') 

		INSERT INTO @FechaAutoriza
	SELECT
		isnull(REPLACE(JSON_VALUE(Parametros, '$.Folio'),'S',''),'')  AS [Folio],
		isnull(JSON_VALUE(Parametros, '$.Mensaje'),'') AS [Aprobada],
		isnull( CONVERT(varchar,JSON_VALUE(Parametros, '$.Fecha'),23),'9999-12-31') AS [FechaAutoriza]
	FROM app.tblNotificaciones	WHERE ISJSON(Parametros) > 0 
		and  JSON_VALUE(Parametros, '$.Mensaje') LIKE  ('%APPROVED%') 


	SELECT 	 
		 M.ClaveEmpleado
		,M.NOMBRECOMPLETO as NombreCompleto
		,M.region as REGION
		,M.Centrocosto as CentroCosto
		,TS.Descripcion as TipoSolicitud
		,ES.Descripcion as Estatus
		,SE.IDIncidencia 
		,I.Descripcion as Incidencia
		,isnull(CONVERT(varchar,SE.FechaIni,23),'9999-12-31') as Fecha
		,ISNULL(SE.CantidadDias,0) as Días
        ,convert(varchar, SE.FechaCreacion, 23) as FechaSolicitud
    	,Utilerias.fnHTMLStr(SE.ComentarioEmpleado) as [COMENTARIOS EMPLEADO]
        --,SE.ComentarioEmpleado
		--,SE.ComentarioSupervisor        
        ,Utilerias.fnHTMLStr(SE.ComentarioSupervisor) as [COMENTARIOS SUPERVISOR]
		,SE.DiasDescanso
		,CASE WHEN us.Nombre IS NOT NULL THEN CONCAT(isnull(us.Nombre,'') ,' ',isnull(us.Apellido,''))
        ELSE (Select top 1 CONCAT(EMP.Nombre,' ',EMP.Paterno) from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado) END AS UsuarioAutoriza	
		--,saldos.Cantidad as CANTIDAD
		--,saldos.IncTomadas as TOMADOS
		--,saldos.IncVencidas as VENCIDOS
		--,saldos.IncDisponibles as DISPONIBLES
		,isnull(cast(FA.FechaAutoriza as varchar(max)),'-') as [FechaAutoriza]
	FROM Intranet.tblSolicitudesEmpleado SE WITH(NOLOCK)
		INNER JOIN RH.tblEmpleadosMaster M WITH(NOLOCK)
			on SE.IDEmpleado = M.IDEmpleado
		INNER JOIN Intranet.tblCatTipoSolicitud TS WITH(NOLOCK)
			on TS.IDTipoSolicitud = SE.IDTipoSolicitud
		INNER JOIN Intranet.tblCatEstatusSolicitudes ES WITH(NOLOCK)
			on ES.IDEstatusSolicitud = SE.IDEstatusSolicitud
		LEFT JOIN Asistencia.tblCatIncidencias I WITH(NOLOCK)
			on SE.IDIncidencia = I.IDIncidencia
        LEFT JOIN Seguridad.tblUsuarios us on us.IDUsuario= SE.IDUsuarioAutoriza
		LEFT JOIN @FechaAutoriza FA  on FA.Folio = SE.IDSolicitud
		--left join  #TempTomados saldos on saldos.IDEmpleado = se.IDEmpleado and saldos.IDIncidencia = se.IDIncidencia
    
	WHERE 
        CAST( SE.FechaCreacion as date) BETWEEN CAST( @FechaIni as date)  and CAST(@FechaFin as date)  
    --         and (se.IDEmpleado = isnull(@Empleados,0)
				--or isnull(@Empleados,0) = 0)
     AND  M.Vigente = 1
	     and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))   
		 		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))              
	--AND (SE.IDEmpleado = @IDEmpleado  OR @IDEmpleado = 0)
	--AND (SE.IDTipoSolicitud = @IDTipoSolicitud OR @IDTipoSolicitud = 0)
	--AND (SE.IDEstatusSolicitud = @IDEstatusSolicitud OR @IDEstatusSolicitud = 0)
	ORDER BY SE.FechaCreacion DESC
END
GO
