USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Norma35].[spIniciarEncuesta](
	@IDEncuestaEmpleado int,
	@IDUsuario int
) as
	declare 
		@IDEncuesta int,
		@IDCatEncuesta int,
		@IDCatGrupo int,
		@IDCatGrupoIdentity int
	;

	if (@IDEncuestaEmpleado > 0 and not exists(select top 1 1 
					from [Norma35].[tblCatGrupos] g with (nolock)
					where TipoReferencia = 2 and IDReferencia = @IDEncuestaEmpleado))
	begin
		select 
			@IDEncuesta = ee.IDEncuesta 
			,@IDCatEncuesta = e.IDCatEncuesta 
		from [Norma35].[tblEncuestasEmpleados] ee with (nolock) 
			join [Norma35].[tblEncuestas] e with (nolock) on e.IDEncuesta = ee.IDEncuesta
		where IDEncuestaEmpleado = @IDEncuestaEmpleado

		if OBJECT_ID('tempdb..#tempGrupos') is not null drop table #tempGrupos;

		select *
		INTO #tempGrupos
		from [Norma35].[tblCatGrupos] g with (nolock)
		where TipoReferencia = 1 and IDReferencia = @IDCatEncuesta

		select @IDCatGrupo = MIN(IDCatGrupo) from #tempGrupos
	
		while exists (select top 1 1 from #tempGrupos where IDCatGrupo >= @IDCatGrupo)
		begin
			insert into [Norma35].[tblCatGrupos](Nombre, IDCatTipoGrupo, TipoReferencia, IDReferencia, RespuestaGrupo, Orden, uuid, uuidDependencia, Nota)
			select Nombre, IDCatTipoGrupo, 2, @IDEncuestaEmpleado, RespuestaGrupo, Orden, uuid, uuidDependencia, Nota
			from #tempGrupos
			where IDCatGrupo = @IDCatGrupo

			set @IDCatGrupoIdentity = @@IDENTITY

			insert into [Norma35].[tblCatPreguntas](IDCatGrupo,Pregunta,IDCatEscala,Orden,IDCategoria,IDDominio,IDDimension)
			select @IDCatGrupoIdentity, Pregunta, IDCatEscala, Orden,IDCategoria, IDDominio, IDDimension
			from [Norma35].[tblCatPreguntas]
			where IDCatGrupo = @IDCatGrupo

			select @IDCatGrupo = MIN(IDCatGrupo) from #tempGrupos where IDCatGrupo > @IDCatGrupo
		end;

		update [Norma35].[tblEncuestasEmpleados]
			set TotalPreguntas = (select COUNT(*)
									from [Norma35].[tblCatGrupos] cg with (nolock)
										join [Norma35].[tblCatPreguntas] p on p.IDCatGrupo = cg.IDCatGrupo
 									where cg.TipoReferencia = 2 and cg.IDReferencia = @IDEncuestaEmpleado) 
									+
								(select COUNT(*)
									from [Norma35].[tblPreguntasExtrasEncuestas]
									where IDEncuesta = @IDEncuesta)
		where IDEncuestaEmpleado = @IDEncuestaEmpleado
	end
		
	exec [Norma35].[spBuscarEncuestasEmpleados] @IDEncuestaEmpleado=@IDEncuestaEmpleado,@IDUsuario=@IDUsuario
GO
