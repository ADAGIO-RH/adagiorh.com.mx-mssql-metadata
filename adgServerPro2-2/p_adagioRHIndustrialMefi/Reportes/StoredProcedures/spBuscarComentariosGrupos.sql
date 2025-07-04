USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar grupos de preguntas y sus comentarios
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-04-05
** Paremetros		: @IDEmpleadoProyecto			- Identificador del empleado proyecto	  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROC [Reportes].[spBuscarComentariosGrupos](
	@IDEmpleadoProyecto INT 
) AS	
	
	DECLARE @dtUsuarios [Seguridad].[dtUsuarios]
			, @PruebaFinal INT = 4
			, @Resultado VARCHAR(250)
			, @Privacidad BIT = 0
			, @PrivacidadDescripcion VARCHAR(25)
			, @ACTIVO BIT = 1


	-- VALIDACION PRUEBAS ANONIMAS
	EXEC [Evaluacion360].[spValidarPruebasAnonimas] 
		@IDEmpleadoProyecto = @IDEmpleadoProyecto
		, @EsRptBasico = 1
		, @Resultado = @Resultado OUTPUT
		, @Descripcion = @PrivacidadDescripcion OUTPUT
		;

	IF(@Resultado <> '0' AND @Resultado <> '1')
		BEGIN					
			RAISERROR(@Resultado, 16, 1); 
			RETURN
		END
	ELSE
		BEGIN
			SET @Privacidad = @Resultado;
		END
	-- TERMINA VALIDACION


	INSERT @dtUsuarios
	EXEC [Seguridad].[spBuscarUsuarios]

	SELECT UPPER(TG.Nombre) + ' - ' + UPPER(G.Nombre) AS Grupo,
		   CTR.Relacion,
		   --CreadoPor = COALESCE(U.Nombre, '') + ' ' + COALESCE(U.Apellido, ''),
		   CreadoPor = CASE 
							WHEN @Privacidad = @ACTIVO
								THEN @PrivacidadDescripcion
								ELSE COALESCE(U.Nombre, '') + ' ' + COALESCE(U.Apellido, '')
							END,
		   G.Comentario
	FROM [Evaluacion360].[tblEmpleadosProyectos] P
		JOIN Evaluacion360.tblEvaluacionesEmpleados EE ON P.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
		JOIN [Evaluacion360].[tblCatGrupos] G ON G.TipoReferencia = @PruebaFinal AND G.IDReferencia = EE.IDEvaluacionEmpleado
		JOIN [Evaluacion360].[tblCatTipoGrupo] TG ON TG.IDTipoGrupo = G.IDTipoGrupo
		JOIN [Evaluacion360].[tblCatTiposRelaciones] CTR ON EE.IDTipoRelacion = CTR.IDTipoRelacion
		JOIN @dtUsuarios U ON EE.IDEvaluador = U.IDEmpleado
	WHERE P.IDEmpleadoProyecto = @IDEmpleadoProyecto AND
		  G.Comentario IS NOT NULL
	ORDER BY G.Nombre, CTR.Relacion
GO
