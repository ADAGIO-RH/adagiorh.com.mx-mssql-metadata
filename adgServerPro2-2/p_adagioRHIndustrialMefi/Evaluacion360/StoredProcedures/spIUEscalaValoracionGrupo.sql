USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spIUEscalaValoracionGrupo](
	@IDEscalaValoracionGrupo	int = 0
	,@IDGrupo	int
	,@Nombre	varchar(100)
	,@Descripcion	varchar(255)
	,@Valor	int
	,@IDUsuario int
) as 
	declare @IDProyecto int
			,@TipoReferencia int ;

	select top 1 @TipoReferencia = TipoReferencia from Evaluacion360.tblCatGrupos where IDGrupo  = @IDGrupo

	if (@TipoReferencia = 1)
	begin
		if exists(select top 1 1
				from evaluacion360.tblcatgrupos cg
					join Evaluacion360.tblCatProyectos p on p.IDProyecto =  cg.IDReferencia
				where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia)
		begin
			select top 1 @IDProyecto = p.IDProyecto
			from evaluacion360.tblcatgrupos cg
				join Evaluacion360.tblCatProyectos p on p.IDProyecto =  cg.IDReferencia
			where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia
		end;
	end;

	if (@TipoReferencia = 4)
	begin
		if exists(select top 1 1
				from evaluacion360.tblcatgrupos cg
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEvaluacionEmpleado =  cg.IDReferencia
					join Evaluacion360.tblEmpleadosProyectos ep on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
				where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia)
		begin
			select top 1 @IDProyecto = ep.IDProyecto
			from evaluacion360.tblcatgrupos cg
				join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEvaluacionEmpleado =  cg.IDReferencia
					join Evaluacion360.tblEmpleadosProyectos ep on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
			where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia
		end;
	end;

	if (@TipoReferencia in (1,4))
	begin
		begin try
			EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
		end try
		begin catch
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
			return 0;
		end catch
	end

	select @Nombre = UPPER(@Nombre)
		,@Descripcion = UPPER(@Descripcion)
		;

	if (len(coalesce(@Nombre,'')) > 0)
	begin
		if (@IDEscalaValoracionGrupo = 0)
		begin
			insert [Evaluacion360].[tblEscalasValoracionesGrupos](IDGrupo,Nombre,Descripcion,Valor)
			values(@IDGrupo,@Nombre,@Descripcion,@Valor)

			set @IDEscalaValoracionGrupo = @@IDENTITY
		end else
		begin
			update [Evaluacion360].[tblEscalasValoracionesGrupos]
				set Nombre = @Nombre
					,Descripcion = @Descripcion
					,Valor = @Valor
			where IDEscalaValoracionGrupo = @IDEscalaValoracionGrupo
		end;
	end

	exec [Evaluacion360].[spBuscarEscalaValoracionGrupo] @IDEscalaValoracionGrupo = @IDEscalaValoracionGrupo
GO
