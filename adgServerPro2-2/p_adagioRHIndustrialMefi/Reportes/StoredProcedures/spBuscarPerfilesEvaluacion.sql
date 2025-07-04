USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los perfiles que tienen evaluaciones completas
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-04-06
** Paremetros		: @IDEmpleadoProyecto			- Identificador del empleado proyecto.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Reportes].[spBuscarPerfilesEvaluacion](
	@IDEmpleadoProyecto	INT = 0
)
AS
BEGIN

	IF OBJECT_ID('tempdb..#tempEvaluacionesCompletas') IS NOT NULL DROP TABLE #tempEvaluacionesCompletas;	

	DECLARE @EstatusEvaluaciones INT = 2,
		    @Completa INT = 13,
			@PruebaFinal INT = 4,
            @IDIdioma VARCHAR(max);
        
select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	-- OBTIENE LAS EVALUACIONES COMPLETAS
	SELECT EE.IDEvaluacionEmpleado,
		   EE.IDTipoRelacion,
		   JSON_VALUE(CTP.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion,
		   EE.IDEvaluador,
		    JSON_VALUE(ESTATUS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) as Estatus
	INTO #tempEvaluacionesCompletas
	FROM [Evaluacion360].[tblEvaluacionesEmpleados] EE WITH(NOLOCK)
		JOIN [Evaluacion360].[tblCatTiposRelaciones] CTP on EE.IDTipoRelacion = CTP.IDTipoRelacion
		JOIN [Evaluacion360].[tblEmpleadosProyectos] EP WITH(NOLOCK) ON EE.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
		LEFT JOIN [Evaluacion360].[tblEstatusEvaluacionEmpleado] EEE WITH(NOLOCK) ON EE.IDEvaluacionEmpleado = EEE.IDEvaluacionEmpleado
		LEFT JOIN (SELECT * FROM [Evaluacion360].[tblCatEstatus] WHERE IDTipoEstatus = @EstatusEvaluaciones) ESTATUS ON EEE.IDEstatus = ESTATUS.IDEstatus
	WHERE EP.IDEmpleadoProyecto = @IDEmpleadoProyecto AND 
		  EEE.IDEstatus = @Completa


	-- OBTIENE LOS TIPOS DE GRUPOS QUE TIENEN EVALUACIONES COMPLETAS
	SELECT TG.IDTipoGrupo,
		   TG.Nombre AS TipoGrupo		   
	FROM [Evaluacion360].[tblCatGrupos] CG
		JOIN #tempEvaluacionesCompletas EC ON CG.IDReferencia = EC.IDEvaluacionEmpleado
		JOIN [Evaluacion360].[tblCatTipoGrupo] TG ON CG.IDTipoGrupo = TG.IDTipoGrupo
	WHERE CG.TipoReferencia = @PruebaFinal
	GROUP BY TG.IDTipoGrupo, TG.Nombre

END
GO
