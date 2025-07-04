USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spIUConfiguracionAvanzadaProyecto](
	 @IDConfiguracionAvanzada int
	,@IDProyecto int
	,@Valor nvarchar(max)
	,@IDUsuario int
) as

	begin try
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	end try
	begin catch
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		return 0;
	end catch
	
	if exists(select top 1 1 
				from [Evaluacion360].[tblConfiguracionAvanzadaProyecto]
				where IDConfiguracionAvanzada = @IDConfiguracionAvanzada and IDProyecto  = @IDProyecto)
	begin
		update [Evaluacion360].[tblConfiguracionAvanzadaProyecto]
			set Valor = @Valor
		where IDConfiguracionAvanzada = @IDConfiguracionAvanzada and IDProyecto  = @IDProyecto
	end else
	begin
		insert into [Evaluacion360].[tblConfiguracionAvanzadaProyecto](IDConfiguracionAvanzada,IDProyecto,Valor)
		select @IDConfiguracionAvanzada,@IDProyecto,@Valor
	end;


	if (@IDConfiguracionAvanzada = 6) -- Todas las preguntas de esta prueba son requeridas:
	begin
		update p
			set	p.EsRequerida = case when LOWER(@Valor) = 'true' then 1 else 0 end
		from [Evaluacion360].[tblCatGrupos] g
			join [Evaluacion360].[tblCatPreguntas] p on g.IDGrupo = p.IDGrupo
		where g.TipoReferencia = 1 and g.IDReferencia = @IDProyecto
	end;

	if (@IDConfiguracionAvanzada = 7) -- Todas las preguntas de escala requieren 9BOX:
	begin
		update p
			set	p.Box9 = case when LOWER(@Valor) = 'true' then 1 else 0 end,
				p.Box9EsRequerido = 0
		from [Evaluacion360].[tblCatGrupos] g
			join [Evaluacion360].[tblCatPreguntas] p on g.IDGrupo = p.IDGrupo
		where g.TipoReferencia = 1 and g.IDReferencia = @IDProyecto 
			  and g.IDTipoPreguntaGrupo NOT IN (1,5) --(MIXTA, FUNCIÓN CLAVE)
	end;

	if (@IDConfiguracionAvanzada = 9) -- Autoevaluacion no es requerida
	begin
		if exists (select top 1 1 
					from [Evaluacion360].[tblEvaluadoresRequeridos]
					where IDTipoRelacion = 4 and IDProyecto = @IDProyecto)
		begin
			update [Evaluacion360].[tblEvaluadoresRequeridos]
				set Minimo = case when LOWER(@Valor) = 'true' then 0 else 1 end
			where IDTipoRelacion = 4 and IDProyecto = @IDProyecto
		end;
	end;

	if (@IDConfiguracionAvanzada = 12) -- Enviar resultado de las pruebas a los colaboradores.
	begin
		MERGE [Evaluacion360].[tblEnviarResultadosAColaboradores] AS TARGET
			USING [Evaluacion360].[tblEmpleadosProyectos] as SOURCE
			on TARGET.IDEmpleadoProyecto = SOURCE.IDEmpleadoProyecto
			WHEN MATCHED THEN
				update 
				 set TARGET.Valor = case when LOWER(@Valor) = 'true' then 1 else 0 end
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleadoProyecto,Valor)
				values(SOURCE.IDEmpleadoProyecto,case when LOWER(@Valor) = 'true' then 1 else 0 end)
			;
	end;
GO
