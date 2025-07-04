USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spBuscarCatReportesBasicosDocx] (
	@IDReporteBasico int = 0
	,@IDAplicacion nvarchar(100) = null
	,@Personalizado bit = null
    ,@Privado bit = null
	,@IDUsuario int
) as
	select 
		r.IDReporteBasico
		,r.IDAplicacion
		,upper(r.Nombre)		as Nombre
		,upper(r.Descripcion)	as Descripcion		
		,r.ConfiguracionFiltros
		,r.Grupos
        ,r.NombreProcedure
		,(Select top 1 RutaRespaldo from app.tblRespaldoReportesTRDP s where s.IDReporteBasico= r.IDReporteBasico and s.RutaRespaldo LIKE '%.docx'  order by IDRespaldoReportesTRDP desc) as NombreReporte
		,isnull(r.Personalizado,0) as Personalizado
		,ROW_NUMBER()OVER(ORDER BY r.IDReporteBasico ASC) as ROWNUMBER
	from Reportes.tblCatReportesBasicos r with (nolock)	
    left join [Seguridad].[vwPermisosUsuariosReportes] pur on pur.IDReporteBasico = r.IDReporteBasico and pur.IDUsuario = @IDUsuario	
	where (r.IDReporteBasico = @IDReporteBasico or ISNULL(@IDReporteBasico,0) = 0) 
	  and (r.IDAplicacion = @IDAplicacion or @IDAplicacion is null)
	  and (isnull(r.Personalizado,0) = @Personalizado or @Personalizado is null)
      and (isnull(r.Privado,0) = @Privado or @Privado is null)
      and (pur.Acceso = 1)
	  --and r.IDReporteBasico in (select IDReporteBasico from Seguridad.tblPermisosReportesUsuarios where IDUsuario = @IDUsuario and isnull(Acceso, 0)= 1)
	order by r.IDAplicacion,r.Nombre asc
GO
