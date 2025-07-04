USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create   proc RH.spBuscarReportesEvaluacionesRenovacionContratosImpresas(
	@IDReporteEvaluacionRenovacionContratoImpresa int = 0,
	@IDUsuario int
) as
	select 
		 erci.IDReporteEvaluacionRenovacionContratoImpresa
		,erci.IDReporteBasico
		,rb.Nombre as Reporte
		,rb.Descripcion as DescripcionReporte
		,coalesce(u.Nombre, '')+ ' '+coalesce(u.Apellido, '') as Usuario
		,erci.IDUsuario
		,erci.FechaHora
		,(
			select 
				r.IDReporteBasico
				,r.IDAplicacion
				,upper(r.Nombre)		as Nombre
				,upper(r.Descripcion)	as Descripcion
				,r.NombreReporte
				,r.ConfiguracionFiltros
				,r.Grupos
				,r.NombreProcedure
				,isnull(r.Personalizado,0) as Personalizado
				,ROW_NUMBER()OVER(ORDER BY r.IDReporteBasico ASC) as ROWNUMBER
			from Reportes.tblCatReportesBasicos r with (nolock)	
			where (r.IDReporteBasico = erci.IDReporteBasico)
			FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER 
		) as ReporteBasico
	from RH.tblReportesEvaluacionesRenovacionContratosImpresas erci
		join Seguridad.tblUsuarios u on u.IDUsuario = erci.IDUsuario
		join Reportes.tblCatReportesBasicos rb on rb.IDReporteBasico = erci.IDReporteBasico
		left join [Seguridad].[vwPermisosUsuariosReportes] pur on pur.IDReporteBasico = rb.IDReporteBasico and pur.IDUsuario = @IDUsuario	
	where (erci.IDReporteEvaluacionRenovacionContratoImpresa = @IDReporteEvaluacionRenovacionContratoImpresa or ISNULL(@IDReporteEvaluacionRenovacionContratoImpresa, 0) = 0)
		and (pur.Acceso = 1)
	order by rb.IDAplicacion,rb.Nombre asc
GO
