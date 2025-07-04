USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las entregas de resultados por proyecto.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-12-23
** Parametros		: @IDProyecto		Identificador del proyecto
**					: @IDUsuario		Identificador del usuario
** IDAzure			: #1303

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spBuscarEntregaDeResultadosEvaluado](
	@IDProyecto		INT = 0
	, @IDUsuario	INT = 0
) AS
	BEGIN
		
		-- VARIABLES
		DECLARE @IDTipoNotificacion	VARCHAR(50) = NULL
				, @IDTipoProyecto		INT = 0				
				, @Tabla				VARCHAR(150)
				, @SQL					NVARCHAR(MAX)
				, @SI					BIT = 1
				;
		
		
		-- OBTENEMOS EL IDTipoProyecto
		SELECT @IDTipoProyecto = IDTipoProyecto FROM [Evaluacion360].[tblCatProyectos] WHERE IDProyecto = @IDProyecto;
	

		-- OBTENEMOS DE LA FUNCION EL IDTipoNotificacion y Tabla A PARTIR DEL @IDTipoProyecto
		SELECT @IDTipoNotificacion = IDTipoNotificacionEvaluado
				, @Tabla = TablaEvaluado
		FROM [Evaluacion360].[fnObtenerNotificacionEntregaDeResultadosEvaluado](@IDTipoProyecto);


		-- OBTENEMOS LAS ENTREGAS DE RESULTADOS NUEVOS DE LA TABLA SOLICITADA
		SET @SQL = N'
					SELECT TBL_DINAMICA.IDEntregaDeResultado 							
							, U.IDUsuario AS IDUsuarioEvaluado
							, TBL_DINAMICA.IDEvaluado AS IDEmpleadoEvaluado
					FROM ' + @Tabla + ' TBL_DINAMICA
						JOIN [Seguridad].[tblUsuarios] U ON TBL_DINAMICA.IDEvaluado = U.IDEmpleado
					WHERE TBL_DINAMICA.IDProyecto = ' + CAST(@IDProyecto AS VARCHAR(25)) + '
							AND TBL_DINAMICA.EnviarResultadoAColaborador = ' + CAST(@SI AS VARCHAR(1)) + '
							AND NOT EXISTS (
											SELECT TOP 1 NA.IDEnviarNotificacionA
											FROM [App].[tblEnviarNotificacionA] NA
												JOIN [App].[tblNotificaciones] N ON NA.IDNotifiacion = N.IDNotifiacion
											WHERE NA.IDMedioNotificacion = ''Email''
												AND NA.TipoReferencia = ''' + @Tabla + '''
												AND NA.IDReferencia = TBL_DINAMICA.IDEntregaDeResultado
												AND N.IDTipoNotificacion = ''' + @IDTipoNotificacion + '''
										   );';
					
					
		--PRINT @SQL;

		-- EJECUTAMOS EL SQL DINÁMICO
		EXEC sp_executesql @SQL;


	END
GO
