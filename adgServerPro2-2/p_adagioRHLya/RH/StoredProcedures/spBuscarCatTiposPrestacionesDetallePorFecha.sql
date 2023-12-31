USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatTiposPrestacionesDetallePorFecha] --1, '2018-01-24','2018-01-24'
(
	@IDTipoPrestacion int,
	@FechaAntiguedad Date,
	@FechaIngreso Date 
)
AS
BEGIN
    if (@FechaAntiguedad = '1900-01-01') set @FechaAntiguedad =getdate()
    if (@FechaIngreso = '1900-01-01') set @FechaIngreso =getdate()

    SELECT top 1
	    ctpd.IDTipoPrestacionDetalle
	    ,ctpd.IDTipoPrestacion
	    ,ctp.Descripcion as TipoPrestacion
	    ,isnull(ctpd.Antiguedad,0) as Antiguedad
	    ,isnull(ctpd.DiasAguinaldo,0) as DiasAguinaldo
	    ,isnull(ctpd.DiasVacaciones,0)as DiasVacaciones
	    ,isnull(ctpd.PrimaVacacional,0.0)as PrimaVacacional
	    ,isnull(ctpd.PorcentajeExtra,0.0)as PorcentajeExtra
	    ,isnull(ctpd.DiasExtras,0)as DiasExtras
	    ,isnull(ctpd.Factor,0.0)as Factor
	FROM [RH].[tblCatTiposPrestacionesDetalle] ctpd
	   join [RH].[TblCatTiposPrestaciones] ctp on ctpd.IDTipoPrestacion = ctp.IDTipoPrestacion
	WHERE (ctpd.IDTipoPrestacion = @IDTipoPrestacion) 
	and --(ctpd.Antiguedad > DATEDIFF(YEAR,@FechaAntiguedad,getdate()))
			(ctpd.Antiguedad > FLOOR(DATEDIFF(day,@FechaAntiguedad,getdate())/365.0))
			--case when DATEDIFF(YEAR,@FechaAntiguedad,getdate()) = 0 then 1 
					   --else DATEDIFF(YEAR,@FechaAntiguedad,getdate()) end )
	 order BY ctpd.Antiguedad asc
		
END
GO
