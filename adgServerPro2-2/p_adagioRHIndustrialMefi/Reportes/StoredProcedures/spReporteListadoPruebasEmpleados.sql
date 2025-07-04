USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--GO
CREATE proc [Reportes].[spReporteListadoPruebasEmpleados](
	@IDPrueba int = 0,
	@ClaveEmpleadoInicial varchar(20) = null,
	@FechaIni date = '1990-01-01',
	@FechaFin date = '9999-12-31',
	@IDUsuario int
) as
	--declare 
	--	@IDPrueba int = 0,
	--	@IDEmpleado int = 0

	set @ClaveEmpleadoInicial = case when @ClaveEmpleadoInicial = '' then null else @ClaveEmpleadoInicial end

	select 
		p.IDPrueba
		,p.Nombre as Prueba
		,p.Descripcion as DescripcionPrueba
		,pe.IDPruebaEmpleado
		,pe.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as NombreCompleto
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,ce.IDCuestionarioEmpleado
		,c.IDCuestionario
		,c.Nombre as Cuestionario
		,c.Descripcion as DescripcionCuestionario
		,Puntuacion = isnull(((select 
							sum (rp.ValorFinal) as Total
						from Salud.tblSecciones s with (nolock)
							join Salud.tblPreguntas p with (nolock) on s.IDSeccion = p.IDSeccion
							left join salud.tblRespuestasPreguntas rp with (nolock) on rp.IDPregunta = p.IDPregunta
						where s.IDCuestionario = c.IDCuestionario
						) * 100.00) / 
						(
						select 
							sum(s.ValorMaximo)
						from Salud.tblSecciones s
						where s.IDCuestionario = c.IDCuestionario
						),
						0.00) 
		,isnull(p.FechaCreacion, getdate()) as FechaPrueba
		,isnull(pe.FechaCreacion,getdate()) as FechaPruebaEmpleado
		,isnull(ce.FechaCreacion,getdate()) as FechaCuestionarioEmpleado
		,isnull(c.FechaCreacion, getdate()) as FechaCuestionario
	from Salud.tblPruebas p with (nolock)
		join Salud.tblPruebasEmpleados pe with (nolock) on pe.IDPrueba = p.IDPrueba
		join Salud.tblCuestionariosEmpleados ce with (nolock) on ce.IDPruebaEmpleado = pe.IDPruebaEmpleado
		join Salud.tblCuestionarios c with (nolock) on c.IDReferencia = ce.IDCuestionarioEmpleado and c.TipoReferencia = 2
		join RH.tblEmpleadosMaster e with (nolock) on e.IDEmpleado = pe.IDEmpleado
	where (p.IDPrueba = @IDPrueba or @IDPrueba = 0) and (e.ClaveEmpleado = @ClaveEmpleadoInicial or @ClaveEmpleadoInicial is null)
		and (CAST(ce.FechaCreacion as date) between @FechaIni and @FechaFin)
	--order by ce.FechaCreacion desc
--select * from Salud.tblPruebasEmpleados
--select * from Salud.tblCuestionarios
--select * from Salud.tblCuestionariosEmpleados
GO
