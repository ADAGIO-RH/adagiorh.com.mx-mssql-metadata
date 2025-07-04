USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Salud].[spCopiarCuestionario](
	@IDCuestionario		int	
	,@TipoReferencia	int
	,@IDReferencia		int 	-- IDCuestionarioEmpleado
	,@IDUsuario			int		
) as 
begin 

	declare 
		@IDCuestionarioNuevo int
		,@IDSeccion int
		,@IDSeccionNueva int
		,@IDPregunta int
		,@IDPreguntaNueva int
	;

	-- Insertamos el cuestionario realacionado a la PruebaEmpleado Recibida en el parámetro @IDReferencia
	insert [Salud].[tblCuestionarios](Nombre, Descripcion,TipoReferencia,IDReferencia,isDefault,IDUsuario)
	select Nombre,Descripcion,@TipoReferencia,@IDReferencia,0,@IDUsuario
	from Salud.tblCuestionarios with (nolock)
	where IDCuestionario = @IDCuestionario

	set @IDCuestionarioNuevo = @@IDENTITY

	if object_id('tempdb..#tempSecciones') is not null drop table #tempSecciones;

	select *
	INTO #tempSecciones
	from [Salud].[tblSecciones] with(nolock)
	where IDCuestionario = @IDCuestionario	

	select @IDSeccion = min(IDSeccion) from #tempSecciones

	while exists (select top 1 1 from #tempSecciones where IDSeccion >= @IDSeccion)
	begin
		insert [Salud].[tblSecciones](IDCuestionario,Nombre,Descripcion,IDUsuario,ValorMaximo)		
		select @IDCuestionarioNuevo,Nombre,Descripcion,@IDUsuario,ValorMaximo
		from Salud.tblSecciones with(nolock) 
		where IDSeccion = @IDSeccion

		set @IDSeccionNueva = @@IDENTITY

		select @IDPregunta = min(IDPregunta)
		from Salud.tblPreguntas with(nolock) 
		where IDSeccion = @IDSeccion

		while exists(select top 1 1 
					from Salud.tblPreguntas with(nolock) 
					where IDSeccion = @IDSeccion and IDPregunta >= @IDPregunta)
		begin
			insert [Salud].[tblPreguntas](IDTipoPregunta,IDSeccion,Descripcion,Calificar,MaximaCalificacionPosible)
			select IDTipoPregunta,@IDSeccionNueva,Descripcion,Calificar,MaximaCalificacionPosible
			from Salud.tblPreguntas with(nolock) 
			where IDPregunta = @IDPregunta

			set @IDPreguntaNueva = @@IDENTITY

			insert [Salud].[tblPosiblesRespuestasPreguntas](IDPregunta,OpcionRespuesta,Valor)
			select @IDPreguntaNueva,OpcionRespuesta,Valor
			from Salud.tblPosiblesRespuestasPreguntas with(nolock) 
			where IDPregunta = @IDPregunta

			select @IDPregunta = min(IDPregunta)
			from Salud.tblPreguntas with(nolock) 
			where IDSeccion = @IDSeccion and IDPregunta > @IDPregunta
		end

		select @IDSeccion = min(IDSeccion) from #tempSecciones where IDSeccion > @IDSeccion
	end;
end
GO
