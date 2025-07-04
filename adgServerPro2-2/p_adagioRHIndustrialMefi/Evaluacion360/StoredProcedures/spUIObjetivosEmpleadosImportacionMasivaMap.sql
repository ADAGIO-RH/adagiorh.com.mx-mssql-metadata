USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: SP para mapeo de importación objetivos empleados
** Autor			: Javier Peña
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2024-01-31
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE   PROCEDURE [Evaluacion360].[spUIObjetivosEmpleadosImportacionMasivaMap] 
	@dtImportacionObjetivosEmpleados [Evaluacion360].[dtImportacionObjetivosEmpleados] READONLY
	,@IDCicloMedicionObjetivo INT	
	, @IDUsuario INT
AS
BEGIN


    DECLARE @EmpleadoApruebaObjetivos BIT
           ,@ID_TIPO_MEDICION_OBJETIVO_FECHA INT = 3
           ,@MENSAJE_TIPO_OBJETIVOS VARCHAR(50) = 'ImportacionObjetivosEmpleados' ;

    SELECT  
        @EmpleadoApruebaObjetivos=isnull(CMO.EmpleadoApruebaObjetivos,CAST(0 AS bit))
    FROM Evaluacion360.tblCatCiclosMedicionObjetivos CMO WITH (NOLOCK)
    WHERE CMO.IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo

    

    DECLARE @tempMessages AS TABLE (
		ID INT
		, [Message] VARCHAR(500)
		, Valid BIT
	);

    INSERT @tempMessages (
		ID
		, [Message]
		, Valid
		)
	SELECT [IDMensajeTipo]
		, [Mensaje]
		, [Valid]
	FROM [RH].[tblMensajesMap] WITH (NOLOCK)
	WHERE [MensajeTipo] = @MENSAJE_TIPO_OBJETIVOS
	ORDER BY [IDMensajeTipo];


    SELECT info.*
		, (
			SELECT m.[Message] AS Message
				, CAST(m.Valid AS BIT) AS Valid
			FROM @tempMessages m
			WHERE ID IN (
					SELECT ITEM
					FROM app.split(info.IDMensaje, ',')
					)
			FOR JSON PATH
			) AS Msg
		, CAST(CASE 
				WHEN EXISTS (
						(
							SELECT m.[Valid] AS Message
							FROM @tempMessages m
							WHERE ID IN (
									SELECT ITEM
									FROM app.split(info.IDMensaje, ',')
									)
								AND Valid = 0
							)
						)
					THEN 0
				ELSE 1
				END AS BIT) AS Valid
	FROM (		
        SELECT 
            ISNULL(e.IDEmpleado,0) AS IDEmpleado,
            s.ClaveEmpleado,
            s.NombreObjetivo,
            s.DescripcionObjetivo,       
            ISNULL(tmo.IDTipoMedicionObjetivo,0) AS IDTipoMedicionObjetivo,            
            s.TipoMedicion,              
            s.Objetivo,
            s.Peso,
            ISNULL(eoe.IDEstatusObjetivoEmpleado,0) AS IDEstatusObjetivoEmpleado,
            s.Estatus,
            ISNULL(cpe.IDPeriodicidad,0) AS IDPeriodicidadActualizacion,
            s.PeriodicidadActualizacion,
            ISNULL(cor.IDOperador,0) AS IDOperador,
            s.Operador,
            s.ValorActual,
            IDMensaje = 
                CASE WHEN e.IDEmpleado IS NULL THEN '1,' ELSE '' END
              + CASE WHEN @EmpleadoApruebaObjetivos= CAST(1 AS BIT) AND S.ValorActual IS NOT NULL THEN '2,' ELSE '' END
              + CASE WHEN LEN(s.NombreObjetivo) > 500 THEN '3,' ELSE '' END
              + CASE WHEN LEN(s.DescripcionObjetivo) > 2147483647 THEN '4,' ELSE '' END
              + CASE WHEN tmo.IDTipoMedicionObjetivo IS NULL THEN '5,' ELSE '' END
              + CASE WHEN eoe.IDEstatusObjetivoEmpleado IS NULL THEN '6,' ELSE '' END
              + CASE WHEN cpe.IDPeriodicidad IS NULL THEN '7,' ELSE '' END
              + CASE WHEN cor.IDOperador IS NULL THEN '8,' ELSE '' END
              + CASE WHEN tmo.IDTipoMedicionObjetivo<>@ID_TIPO_MEDICION_OBJETIVO_FECHA AND TRY_CONVERT(FLOAT, s.Objetivo) IS NULL THEN '9,' ELSE '' END
              + CASE WHEN tmo.IDTipoMedicionObjetivo<>@ID_TIPO_MEDICION_OBJETIVO_FECHA AND TRY_CONVERT(FLOAT, ISNULL(s.ValorActual,0)) IS NULL THEN '10,' ELSE '' END
              + CASE WHEN tmo.IDTipoMedicionObjetivo<>@ID_TIPO_MEDICION_OBJETIVO_FECHA AND TRY_CONVERT(FLOAT, s.Objetivo) IS NOT NULL AND TRY_CONVERT(FLOAT, s.Objetivo)<0 THEN '11,' ELSE '' END
              + CASE WHEN tmo.IDTipoMedicionObjetivo<>@ID_TIPO_MEDICION_OBJETIVO_FECHA AND TRY_CONVERT(FLOAT, ISNULL(s.ValorActual,0)) IS NOT NULL AND TRY_CONVERT(FLOAT, s.ValorActual)<0 THEN '12,' ELSE '' END
              + CASE WHEN TRY_CONVERT(FLOAT, s.Peso) IS NOT NULL AND s.Peso<0 THEN '13,' ELSE '' END
              + CASE WHEN TRY_CONVERT(FLOAT, s.Peso) IS NULL THEN '14,' ELSE '' END
              + CASE WHEN NombreObjetivo IS NULL THEN '15,' ELSE '' END

        FROM @dtImportacionObjetivosEmpleados s
        LEFT JOIN rh.tblempleados e 
             ON e.ClaveEmpleado = s.ClaveEmpleado
        LEFT JOIN app.tblCatOperadoresRacionales cor 
            ON cor.Operador = s.Operador
        LEFT JOIN Evaluacion360.tblCatTiposMedicionesObjetivos tmo 
            ON JSON_VALUE(tmo.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE('esmx', '-','')), 'Nombre')) = s.TipoMedicion
        LEFT JOIN Evaluacion360.tblCatEstatusObjetivosEmpleado eoe 
            ON JSON_VALUE(eoe.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE('esmx', '-','')), 'Nombre')) = s.Estatus
        LEFT JOIN app.tblCatPeriodicidades cpe 
            ON JSON_VALUE(cpe.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE('esmx', '-','')), 'Periodicidad')) = s.PeriodicidadActualizacion
		) info
	ORDER BY info.ClaveEmpleado

    

END
GO
