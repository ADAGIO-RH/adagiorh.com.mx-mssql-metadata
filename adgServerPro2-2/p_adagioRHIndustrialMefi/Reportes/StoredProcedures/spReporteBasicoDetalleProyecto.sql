USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Reportes].[spReporteBasicoDetalleProyecto](
	@IDProyecto int,
	@IDUsuario int
) as
    SET NOCOUNT ON;  
     IF 1=0 BEGIN  
       SET FMTONLY OFF  
     END  

	declare  
		@Resultado VARCHAR(250)
		,@Privacidad BIT = 0
		,@PrivacidadDescripcion VARCHAR(25)
		,@ACTIVO BIT = 1
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
	;

	SET DATEFIRST 7;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL;
 
	-- VALIDACION PRUEBAS ANONIMAS
	EXEC [Evaluacion360].[spValidarPruebasAnonimas] 
		@IDProyecto = @IDProyecto
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

	select 
		CASE 
			WHEN @Privacidad = @ACTIVO
				THEN @PrivacidadDescripcion
				ELSE colaborador.ClaveEmpleado
			END	as [CLAVE COLABORADOR],
		CASE 
			WHEN @Privacidad = @ACTIVO
				THEN @PrivacidadDescripcion
				ELSE colaborador.NOMBRECOMPLETO
			END	as COLABORADOR,
		colaborador.Departamento	as [DEPARTAMENTO COLABORADOR],
		colaborador.RazonSocial		as [RAZÓN SOCIAL COLABORADOR],
		colaborador.Puesto		as [PUESTO COLABORADOR],
		CASE 
			WHEN @Privacidad = @ACTIVO
				THEN @PrivacidadDescripcion
				ELSE evaluador.ClaveEmpleado
			END	as [CLAVE EVALUADOR],
		CASE 
			WHEN @Privacidad = @ACTIVO
				THEN @PrivacidadDescripcion
				ELSE evaluador.NOMBRECOMPLETO
			END	as EVALUADOR,
		evaluador.Departamento		as [DEPARTAMENTO EVALUADOR],
		evaluador.RazonSocial		as [RAZÓN SOCIAL EVALUADOR],
		evaluador.Puesto		as [PUESTO EVALUADOR],
		tp.Relacion as RELACION,
		g.Nombre as GRUPO,
		p.Descripcion as PREGUNTA,
		isnull(i.Nombre, 'NINGUNO') as INDICADOR,
		rp.Respuesta as RESPUESTA,
		[VALOR FINAL] = case when rp.ValorFinal = -1 then null else rp.ValorFinal end
	from Evaluacion360.tblEmpleadosProyectos ep
		join RH.tblEmpleadosMaster colaborador			on colaborador.IDEmpleado = ep.IDEmpleado
		join Evaluacion360.tblEvaluacionesEmpleados ee	on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join RH.tblEmpleadosMaster evaluador	on evaluador.IDEmpleado = ee.IDEvaluador
		join Evaluacion360.tblCatTiposRelaciones tp on tp.IDTipoRelacion = ee.IDTipoRelacion
		join Evaluacion360.tblCatGrupos g		on g.IDReferencia = ee.IDEvaluacionEmpleado and g.TipoReferencia = 4
		join Evaluacion360.tblCatPreguntas p	on p.IDGrupo = g.IDGrupo and isnull(p.Calificar, 0) = 1
		left join Evaluacion360.tblCatIndicadores i on i.IDIndicador = p.IDIndicador
		left join Evaluacion360.tblRespuestasPreguntas rp on rp.IDPregunta = p.IDPregunta
	where ep.IDProyecto = @IDProyecto 
	order by p.Descripcion
GO
