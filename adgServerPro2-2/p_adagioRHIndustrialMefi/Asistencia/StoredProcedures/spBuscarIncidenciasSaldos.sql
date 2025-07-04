USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Asistencia].[spBuscarIncidenciasSaldos](      
	@IDIncidenciaSaldo INT = NULL,
	@IDEmpleado INT,
	@IDIncidencia varchar(20) = null,
	@IDUsuario int,
	@PageNumber	INT = 1,
	@PageSize INT = 2147483647,
	@query VARCHAR(100) = '""',
	@orderByColumn	VARCHAR(50) = 'Descripcion',
	@orderDirection VARCHAR(4) = 'asc'
)      
AS      
	BEGIN  

		SET FMTONLY OFF;

		DECLARE  
			@IDIdioma varchar(225),
			@TotalPaginas INT = 0,
			@TotalRegistros DECIMAL(18,2) = 0.00,
			@Counter int = 1,
			@FechaIni DATE,
			@FechaFin DATE,
			@IDIncidenciaTomada VARCHAR(10),
			@IncTomadas INT = 0
		;

		select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
		
		IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
		IF(isnull(@PageSize, 0) = 0) SET @PageSize = 2147483647;

		SELECT
			 @orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'Descripcion' ELSE @orderByColumn END,
			 @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'asc' ELSE @orderDirection END 

		DECLARE @TempIncSaldos AS TABLE (
			ID INT
		)  
   
		SET @query = CASE 
						WHEN @query IS NULL THEN '""' 
						WHEN @query = '' THEN '""'
						WHEN @query = '""' THEN @query
					ELSE '"' + @query + '*"' END

		DECLARE @tempResponse AS TABLE (
			ID INT IDENTITY(1,1),
			IDIncidenciaSaldo INT,
			IDIncidencia VARCHAR(10),
			Descripcion VARCHAR(255),
			FechaInicio DATE,
			FechaFin DATE,
			FechaRegistro DATETIME,
			Cantidad INT,
			IncTomadas INT,
			IncVencidas INT,
			IncDisponibles INT
		);

		INSERT @tempResponse
		SELECT       
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
		FROM [Asistencia].[tblIncidenciasSaldos] S WITH (NOLOCK)
			INNER JOIN [Asistencia].[tblCatIncidencias] I WITH (NOLOCK) ON S.IDIncidencia = I.IDIncidencia
		WHERE S.IDEmpleado = @IDEmpleado AND
				(s.IDIncidencia = @IDIncidencia or isnull(@IDIncidencia, '') = '') and
			  ((S.IDIncidenciaSaldo = @IDIncidenciaSaldo OR ISNULL(@IDIncidenciaSaldo, 0) = 0)) AND
			  (S.IDIncidenciaSaldo IN (SELECT ID FROM @TempIncSaldos) OR NOT EXISTS(SELECT ID FROM @TempIncSaldos)) AND 
			  (@query = '""' OR CONTAINS(I.*, @query))

		WHILE(@Counter <= (SELECT COUNT(ID) FROM @tempResponse))
		BEGIN
			SELECT 
				@IDIncidenciaTomada = IDIncidencia, 
				@FechaIni = FechaInicio, 
				@FechaFin = FechaFin 
			FROM @tempResponse 
			WHERE ID = @Counter;
				
			SET @IncTomadas = [Asistencia].[fnBuscarIncidenciasEmpleado](@IDEmpleado, @IDIncidenciaTomada, @FechaIni, @FechaFin);
				
			UPDATE @tempResponse  
				SET IncTomadas = @IncTomadas,
					IncVencidas = CASE WHEN ((DATEDIFF(DAY, GETDATE(), @FechaFin )) < 0) THEN Cantidad - @IncTomadas ELSE 0 END,
					IncDisponibles = CASE WHEN ((DATEDIFF(DAY, GETDATE(), @FechaFin )) >= 0) then Cantidad - @IncTomadas ELSE 0 END
			WHERE ID = @Counter;

			SET @Counter = @Counter + 1
		END	

		SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
		FROM @tempResponse

		SELECT @TotalRegistros = CAST(COUNT([IDIncidenciaSaldo]) AS DECIMAL(18,2)) FROM @tempResponse		

		SELECT *,
			   TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END
		FROM @tempResponse
		ORDER BY 
			CASE WHEN @orderByColumn = 'Descripcion' AND @orderDirection = 'asc'  THEN Descripcion END,
			CASE WHEN @orderByColumn = 'Descripcion' AND @orderDirection = 'desc' THEN Descripcion END DESC,
			Descripcion ASC
		OFFSET @PageSize * (@PageNumber - 1) ROWS
		FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

	END
GO
