USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoComentariosPreguntas] (
	@dtFiltros Nomina.dtFiltrosRH readonly,
	@IDusuario int
) as
	SET NOCOUNT ON;
    IF 1=0 BEGIN
		SET FMTONLY OFF
    END

	declare  
		@IDProyecto int 
		,@Resultado VARCHAR(250)
		,@Privacidad BIT = 0
		,@PrivacidadDescripcion VARCHAR(25)
		,@ACTIVO BIT = 1
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
	;

	select @IDProyecto = cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDProyecto'),',')

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

	Select 
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
		catp.Descripcion as PREGUNTA, 
		comentario.Comentario AS COMENTARIO,
		LEFT(DATENAME(WEEKDAY,isnull(comentario.FechaHora,getdate())),3) + ' ' +
			CONVERT(VARCHAR(6),isnull(comentario.FechaHora,getdate()),106) 
			+ ' '+convert(varchar(4),datepart(year,isnull(comentario.FechaHora,getdate()) ))
			FECHA
	from Evaluacion360.tblEmpleadosProyectos ep
		join Evaluacion360.tblEvaluacionesEmpleados eve on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto
		join Evaluacion360.tblCatGrupos catc on catc.TipoReferencia = 4  and catc.IDReferencia = eve.IDEvaluacionEmpleado
		join Evaluacion360.tblCatPreguntas catp on catp.IDGrupo = catc.IDGrupo
		join [Evaluacion360].[tblComentariosPregunta] comentario on comentario.IDPregunta = catp.IDPregunta
		left join RH.tblEmpleadosMaster colaborador on colaborador.IDEmpleado = ep.IDEmpleado
		left join RH.tblEmpleadosMaster evaluador on evaluador.IDEmpleado = eve.IDEvaluador
	where ep.IDProyecto = @IDProyecto
GO
