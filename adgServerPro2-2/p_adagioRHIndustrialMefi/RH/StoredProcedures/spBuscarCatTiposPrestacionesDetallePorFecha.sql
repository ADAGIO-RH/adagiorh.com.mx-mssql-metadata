USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Unknown
-- Create date: Unknown
-- Description: 
-- Julio Castillo 08/11/2023
-- Se le agregó control de errores para que no regrese un dataset vacio y el usuario pueda conocer el error. 

CREATE PROCEDURE [RH].[spBuscarCatTiposPrestacionesDetallePorFecha] --6, '2019-11-20','2021-10-19'
(
	@IDTipoPrestacion int,
	@FechaAntiguedad Date,
	@FechaMovimiento Date,
    @IDUsuario int = 1 
)
AS
BEGIN


    if (@FechaAntiguedad = '1900-01-01') set @FechaAntiguedad =getdate()
    if (@FechaMovimiento = '1900-01-01') set @FechaMovimiento =getdate()
    
    
    if (@IDTipoPrestacion = 0) 
    begin
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '', @CustomMessage= 'Error, el colaborador no tiene prestacion asignada' 
    return
    end


    if not exists ( 
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
            ,isnull(ctpd.Factor,0.00000)as Factor
        FROM [RH].[tblCatTiposPrestacionesDetalle] ctpd
        join [RH].[TblCatTiposPrestaciones] ctp on ctpd.IDTipoPrestacion = ctp.IDTipoPrestacion
        WHERE (ctpd.IDTipoPrestacion = @IDTipoPrestacion) 
        and (ctpd.Antiguedad > FLOOR(DATEDIFF(day,@FechaAntiguedad,@FechaMovimiento)/365.0))				
        order BY ctpd.Antiguedad asc
        )  
	begin 
		exec app.spObtenerError @IDUsuario= @IDUsuario, @CodigoError='0410002'  
		return  
	end;  


    SELECT top 1
	    ctpd.IDTipoPrestacionDetalle
	    ,ctpd.IDTipoPrestacion
	    ,(JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion'))) as TipoPrestacion
	    ,isnull(ctpd.Antiguedad,0) as Antiguedad
	    ,isnull(ctpd.DiasAguinaldo,0) as DiasAguinaldo
	    ,isnull(ctpd.DiasVacaciones,0)as DiasVacaciones
	    ,isnull(ctpd.PrimaVacacional,0.0)as PrimaVacacional
	    ,isnull(ctpd.PorcentajeExtra,0.0)as PorcentajeExtra
	    ,isnull(ctpd.DiasExtras,0)as DiasExtras
	    ,isnull(ctpd.Factor,0.00000)as Factor
	FROM [RH].[tblCatTiposPrestacionesDetalle] ctpd
	   join [RH].[TblCatTiposPrestaciones] ctp on ctpd.IDTipoPrestacion = ctp.IDTipoPrestacion
	WHERE (ctpd.IDTipoPrestacion = @IDTipoPrestacion) 
	and (ctpd.Antiguedad > FLOOR(DATEDIFF(day,@FechaAntiguedad,@FechaMovimiento)/365.0))
						--case when DATEDIFF(YEAR,@FechaAntiguedad,getdate()) = 0 then 1 
					   --else DATEDIFF(YEAR,@FechaAntiguedad,getdate()) end )
	 order BY ctpd.Antiguedad asc
		
END
GO
