USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Reportes].[spEjecutaReporteBasico](
	 @IDReporteBasico int
	,@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as

	declare @spReporteBasico nvarchar(255)           

	select @spReporteBasico=NombreProcedure                  
	from Reportes.tblCatReportesBasicos
	where IDReporteBasico = @IDReporteBasico     

	print @spReporteBasico
	exec sp_executesql N'exec @miSP @dtFiltros,@IDUsuario '                   
			     ,N' @dtFiltros [Nomina].[dtFiltrosRH] READONLY                   
					,@IDUsuario int                   
					,@miSP varchar(255)',                          
				@dtFiltros = @dtFiltros                  
				,@IDUsuario = @IDUsuario              
				,@miSP = @spReporteBasico ;
GO
