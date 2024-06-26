USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spBuscarCatReportesBasicos] (
	@IDReporteBasico int = 0
	,@IDAplicacion nvarchar(100) = null
	,@Personalizado bit = null
	,@IDUsuario int
) as

	select IDReporteBasico
		  ,IDAplicacion
		  ,upper(Nombre)		as Nombre
		  ,upper(Descripcion)	as Descripcion
		  ,NombreReporte
		  ,ConfiguracionFiltros
		  ,Grupos
		  ,NombreProcedure
		  ,isnull(Personalizado,0) as Personalizado
		  ,ROW_NUMBER()OVER(ORDER BY IDReporteBasico ASC) as ROWNUMBER
	from Reportes.tblCatReportesBasicos with (nolock)
	where (IDReporteBasico = @IDReporteBasico or ISNULL(@IDReporteBasico,0) = 0) 
	  and (IDAplicacion = @IDAplicacion or @IDAplicacion is null)
	  and (isnull(Personalizado,0) = @Personalizado or @Personalizado is null)
	order by IDAplicacion,Nombre asc
GO
