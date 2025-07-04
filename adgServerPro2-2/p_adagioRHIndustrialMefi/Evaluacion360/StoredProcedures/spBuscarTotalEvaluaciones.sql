USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc Evaluacion360.spBuscarTotalEvaluaciones(
		@IDProyecto INT,
		@IDUsuario	INT
) as
	DECLARE 
		@RelacionesProyecto Evaluacion360.dtRelacionesProyectoFilter,
		@Total DECIMAL(18,2)
	;

	INSERT @RelacionesProyecto
	EXEC [Evaluacion360].[spBuscarRelacionesProyectoFilter]
		@IDProyecto = @IDProyecto,
		@IDUsuario = @IDUsuario

	select @Total = COUNT(*) from @RelacionesProyecto

	select rp.Relacion, tr.Color, CAST((CAST(count(*) AS decimal(18,2)) *100.00) / @Total AS decimal(18,2)) as Total
	from @RelacionesProyecto rp
		join [Evaluacion360].[tblCatTiposRelaciones] tr on tr.IDTipoRelacion = rp.IDTipoRelacion
	group by rp.Relacion, tr.Color

	select isnull(rp.Estatus, 'SIN ESTATUS') as Estatus, isnull(e.Color, '#000') as Color, CAST((CAST(count(*) AS decimal(18,2)) *100.00) / @Total AS decimal(18,2)) as Total
	from @RelacionesProyecto rp
		left join [Evaluacion360].[tblCatEstatus] e on e.IDEstatus = rp.IDEstatus
	group by rp.Estatus, e.Color
GO
