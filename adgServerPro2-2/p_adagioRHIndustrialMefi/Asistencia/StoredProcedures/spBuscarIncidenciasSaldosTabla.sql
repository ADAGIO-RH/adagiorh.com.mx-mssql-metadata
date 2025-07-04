USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Asistencia].[spBuscarIncidenciasSaldosTabla](      
	@IDUsuario int
	,@dtPagination [Nomina].[dtFiltrosRH] READONLY              
    ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY  
)      
AS      
	BEGIN  

		SET FMTONLY OFF;

		DECLARE  
			@IDIncidenciaSaldo INT = NULL,
			@IDIdioma varchar(225),	
			@Counter int = 1,
			@FechaIni DATE,
			@FechaFin DATE,
			@IDIncidenciaTomada VARCHAR(10),
			@IncTomadas INT = 0,
			@IDIncidencia varchar(4)='',
			@IDEmpleado int = 0,		
			@IDTipoSolicitud int = 0,
			@IDEstatusSolicitud int = 0,
			@IDEstatusSolicitudPrestamos int = 0,	 
			@orderByColumn	varchar(50) = 'Incidencia',
			@orderDirection varchar(4) = 'asc' 
		;

		select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
		
		 IF OBJECT_ID(N'tempdb..#tempSetPagination') IS NOT NULL DROP TABLE #tempSetPagination

		  Select  @orderByColumn=isnull(Value,'Descripcion') from @dtPagination where Catalogo = 'orderByColumn'
    Select  @orderDirection=isnull(Value,'asc') from @dtPagination where Catalogo = 'orderDirection'



		DECLARE @TempIncSaldos AS TABLE (
			ID INT
		)  
   

	
		SELECT       
			
		        ROW_NUMBER()Over(Order by  
            case when @orderByColumn = 'Incidencia' and @orderDirection = 'asc'		then JSON_VALUE(I.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) end,
            case when @orderByColumn = 'Incidencia' and @orderDirection = 'desc'	then JSON_VALUE(I.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  end asc


        )  as [row],
			S.IDIncidenciaSaldo,
			S.IDIncidencia,
			JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion,
			S.FechaInicio,
			S.FechaFin,
			S.FechaRegistro,
			S.Cantidad,
			0 AS IncTomadas,
			0 AS IncVencidas,
			0 AS IncDisponibles
		into #tempSetPagination
		FROM [Asistencia].[tblIncidenciasSaldos] S WITH (NOLOCK)
			INNER JOIN [Asistencia].[tblCatIncidencias] I WITH (NOLOCK) ON S.IDIncidencia = I.IDIncidencia
		WHERE S.IDEmpleado = @IDEmpleado AND
				(s.IDIncidencia = @IDIncidencia or isnull(@IDIncidencia, '') = '') and
			  ((S.IDIncidenciaSaldo = @IDIncidenciaSaldo OR ISNULL(@IDIncidenciaSaldo, 0) = 0)) AND
			  (S.IDIncidenciaSaldo IN (SELECT ID FROM @TempIncSaldos) OR NOT EXISTS(SELECT ID FROM @TempIncSaldos)) 

		WHILE(@Counter <= (SELECT COUNT([row]) FROM #tempSetPagination))
		BEGIN
			SELECT 
				@IDIncidenciaTomada = IDIncidencia, 
				@FechaIni = FechaInicio, 
				@FechaFin = FechaFin 
			FROM #tempSetPagination 
			WHERE [row] = @Counter;
				
			SET @IncTomadas = [Asistencia].[fnBuscarIncidenciasEmpleado](@IDEmpleado, @IDIncidenciaTomada, @FechaIni, @FechaFin);
				
			UPDATE #tempSetPagination  
				SET IncTomadas = @IncTomadas,
					IncVencidas = CASE WHEN ((DATEDIFF(DAY, GETDATE(), @FechaFin )) < 0) THEN Cantidad - @IncTomadas ELSE 0 END,
					IncDisponibles = CASE WHEN ((DATEDIFF(DAY, GETDATE(), @FechaFin )) >= 0) then Cantidad - @IncTomadas ELSE 0 END
			WHERE [row] = @Counter;

			SET @Counter = @Counter + 1
		END	

	    if exists(select top 1 * from @dtPagination)
    BEGIN
        exec [Utilerias].[spAddPagination] @dtPagination=@dtPagination
    end else 
    begin 
        select  * From #tempSetPagination order by row desc
    end
	END
GO
