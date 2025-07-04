USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc Salud.spFinalizarPrueba(
	@IDCuestionario int,
	@IDUsuario int
) as 

	declare 
		--@IDCuestionario int =  102, --60,
		@IDCuestionarioEmpleado int,
		@Personalizada varchar(255),

		@ValorTotalPrueba decimal(18,2) = 0.00,
		@ValorTotalRespuestas decimal(18,2) = 0.00,
		@Respuesta varchar(max)
	;


	select @IDCuestionarioEmpleado = IDReferencia
	from Salud.tblCuestionarios
	where IDCuestionario = @IDCuestionario

	select @Personalizada = p.Personalizada
	from Salud.tblCuestionariosEmpleados ce
		join Salud.tblPruebasEmpleados pe on pe.IDPruebaEmpleado = ce.IDPruebaEmpleado
		join Salud.tblPruebas p on p.IDPrueba = pe.IDPrueba
	where ce.IDCuestionarioEmpleado = @IDCuestionarioEmpleado

	if (@Personalizada = 'Covid19') 
	begin
		if OBJECT_ID('tempdb..#tempRespuestas') is not null drop table #tempRespuestas;
		select 
			p.Descripcion as Pregunta
			,Respuesta = case 
						when p.IDTipoPregunta in (1,2) then prp.OpcionRespuesta
						when p.IDTipoPregunta = 4 then rp.Respuesta
						 else rp.Respuesta end 
		INTO #tempRespuestas
		from [Salud].[tblCuestionariosEmpleados] ce with (nolock)
			join [Salud].[tblCuestionarios] c with (nolock) on c.IDReferencia = ce.IDCuestionarioEmpleado and c.TipoReferencia = 2
			join [Salud].[tblSecciones] s with (nolock) on s.IDCuestionario = c.IDCuestionario
			join [Salud].[tblPreguntas] p with (nolock) on p.IDSeccion = s.IDSeccion
			join [Salud].[tblRespuestasPreguntas] rp with (nolock) on rp.IDPregunta = p.IDPregunta
			left join [Salud].[tblPosiblesRespuestasPreguntas] prp with (nolock) on 
					prp.IDPregunta = p.IDPregunta and 
					prp.IDPosibleRespuesta in (select case when p.IDTipoPregunta in (1,2)  then cast(item as int) else 0 end from App.Split(rp.Respuesta,',')) 
		where ce.IDCuestionarioEmpleado = @IDCuestionarioEmpleado

		set @Respuesta = (select top 1 Respuesta from #tempRespuestas where Pregunta = 'CATEGORIA DE RIESGO')+' ('+(select top 1 Respuesta from #tempRespuestas where Pregunta = 'NIVEL DE RIESGO')+'%)'

		update Salud.tblCuestionariosEmpleados
			set Resultado = @Respuesta
		where IDCuestionarioEmpleado = @IDCuestionarioEmpleado
	end
	else
	begin
		select 
			@ValorTotalPrueba = sum(s.ValorMaximo)
		from Salud.tblSecciones s with (nolock)
		where s.IDCuestionario = @IDCuestionario

		select 
			@ValorTotalRespuestas = isnull(sum(rp.ValorFinal),0)
		from Salud.tblSecciones s with (nolock)
			join Salud.tblPreguntas p with (nolock) on s.IDSeccion = p.IDSeccion
			left join salud.tblRespuestasPreguntas rp with (nolock) on rp.IDPregunta = p.IDPregunta
		where s.IDCuestionario = @IDCuestionario

		update Salud.tblCuestionariosEmpleados
			set Resultado = cast((@ValorTotalRespuestas * 100) / @ValorTotalPrueba as decimal(18,2))
		where IDCuestionarioEmpleado = @IDCuestionarioEmpleado
	end

	--select *
	--from Salud.tblCuestionariosEmpleados ce
	--where ce.IDCuestionarioEmpleado = @IDCuestionarioEmpleado
GO
