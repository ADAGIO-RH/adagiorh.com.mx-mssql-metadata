USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spBuscarComentariosPreguntas](
	@IDEmpleadoProyecto int 
) as
--declare
--	@IDProyecto int = 64
--	,@IDEmpleadoProyecto int = 42282
--	;

	declare @dtUsuarios [Seguridad].[dtUsuarios]
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
    DECLARE @IDIdioma varchar(max)
select @IDIdioma =App.fnGetPreferencia('Idioma',1,'esmx')



	insert @dtUsuarios
	exec [Seguridad].[spBuscarUsuarios]

	select 
		--coalesce(ctr.Relacion,'')+': '+pre.Descripcion as Pregunta
		pre.Descripcion as Pregunta
		--,ctr.Relacion
		--,u.Nombre
		--,CreadoPor = coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'')--+' ('+coalesce(ctr.Relacion,'')+')'
		, CreadoPor = CASE 
						WHEN @Privacidad = @ACTIVO
							THEN @PrivacidadDescripcion
							ELSE coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'')
						END
		,cp.Comentario
		,JSON_VALUE(ctr.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
	from Evaluacion360.tblEmpleadosProyectos p 
		join Evaluacion360.tblEvaluacionesEmpleados ee on p.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
		join [Evaluacion360].[tblCatGrupos] g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
		join [Evaluacion360].[tblCatPreguntas] pre on pre.IDGrupo = g.IDGrupo
		join [Evaluacion360].[tblComentariosPregunta] cp on cp.IDPregunta = pre.IDPregunta
		join [Evaluacion360].[tblCatTiposRelaciones] ctr on ee.IDTipoRelacion = ctr.IDTipoRelacion
		join @dtUsuarios u on cp.IDUsuario = u.IDUsuario
	where p.IDEmpleadoProyecto = @IDEmpleadoProyecto
	order by pre.Descripcion asc
GO
