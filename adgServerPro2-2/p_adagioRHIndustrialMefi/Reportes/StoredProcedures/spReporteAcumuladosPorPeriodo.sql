USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spReporteAcumuladosPorPeriodo](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) 
AS

DECLARE   
		@IDPeriodoSeleccionado int=0      
	   ,@IDCliente int
	;  
	Select @IDPeriodoSeleccionado= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')
	Select @IDCliente	= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')

BEGIN
	select 
	CC.Codigo as CODIGO
	,CC.Descripcion as CONCEPTO
	,TP.Descripcion as [TIPO CONCEPTO]
	, ISNULL(sum(DP.ImporteTotal1),0) as TOTALES
	from Nomina.tblCatConceptos CC with(nolock)
	inner join Nomina.tblCatTipoConcepto TP with(nolock) on CC.IDTipoConcepto = TP.IDTipoConcepto
	left join Nomina.tblDetallePeriodo DP with(nolock) on DP.IDConcepto = CC.IDConcepto and DP.IDPeriodo = @IDPeriodoSeleccionado
	inner join Nomina.tblcatperiodos p with(nolock) on p.IDPeriodo = dp.IDPeriodo
	where isnull(P.Cerrado,0) = 1
	group by CC.Codigo,CC.Descripcion,TP.Descripcion
	order by CC.Codigo
END
GO
