USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc Reportes.spReporteResultadosPruebaSalud(
	@IDCuestionarioEmpleado int,
	@IDUsuario int
) as
	--declare 
	--	@IDCuestionarioEmpleado int = 84-- 81
	--;

	--select * from Salud.tblCuestionarios where IDCuestionario = 103
	select 
		 e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,prueba.Nombre as Prueba
		,c.Nombre as Cuestionario
		,s.Nombre as Seccion
		,p.Descripcion as Pregunta
		--,prp.OpcionRespuesta
		,Respuesta = case 
					when p.IDTipoPregunta in (1,2) then prp.OpcionRespuesta
					when p.IDTipoPregunta = 4 then rp.Respuesta
					 else rp.Respuesta end 
	from [Salud].[tblCuestionariosEmpleados] ce with (nolock)
		join [Salud].[tblPruebasEmpleados] pe with (nolock) on pe.IDPruebaEmpleado = ce.IDPruebaEmpleado
		join [Salud].[tblPruebas] prueba with (nolock) on prueba.IDPrueba = pe.IDPrueba
		join [RH].[tblEmpleadosMaster] e on e.IDEmpleado = pe.IDEmpleado
		join [Salud].[tblCuestionarios] c with (nolock) on c.IDReferencia = ce.IDCuestionarioEmpleado and c.TipoReferencia = 2
		join [Salud].[tblSecciones] s with (nolock) on s.IDCuestionario = c.IDCuestionario
		join [Salud].[tblPreguntas] p with (nolock) on p.IDSeccion = s.IDSeccion
		join [Salud].[tblRespuestasPreguntas] rp with (nolock) on rp.IDPregunta = p.IDPregunta
		left join [Salud].[tblPosiblesRespuestasPreguntas] prp with (nolock) on 
				prp.IDPregunta = p.IDPregunta and 
				prp.IDPosibleRespuesta in (select case when p.IDTipoPregunta in (1,2)  then cast(item as int) else 0 end from App.Split(rp.Respuesta,',')) 
		--left join [Salud].[tblPosiblesRespuestasPreguntas] prp3 on prp3.IDPregunta = p.IDPregunta and p.IDTipoPregunta = 4
	where ce.IDCuestionarioEmpleado = @IDCuestionarioEmpleado-- and isnull(p.Calificar,0) = 0 and p.IDTipoPregunta not in (1,8,9)
	order by p.Descripcion

	--select * from Evaluacion360.tblPosiblesRespuestasPreguntas where IDPregunta = 5448

	--select * from salud.tblTiposDePreguntas

	--select cast('43.3' as int)
GO
