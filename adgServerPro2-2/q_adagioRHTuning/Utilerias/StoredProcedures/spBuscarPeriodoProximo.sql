USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Utilerias].[spBuscarPeriodoProximo](
     @IDPeriodo int 
    ,@Opcion bit ---1 PROXIMO, 0 ANTERIOR

) as
    DECLARE 
        @FechaIniPagoPeriodoOriginal date,
        @FechaFinPagoPeriodoOriginal date,
        @IDTipoNomina int
        ;

    SELECT 
            @FechaIniPagoPeriodoOriginal=FechaInicioPago
           ,@FechaFinPagoPeriodoOriginal=FechaFinPago
           ,@IDTipoNomina=IDTipoNomina
    FROM NOMINA.tblCatPeriodos
    WHERE IDPERIODO=@IDPeriodo


    if(@Opcion=1)
    BEGIN
        SELECT TOP 1 *
        FROM Nomina.tblCatPeriodos
        WHERE FechaInicioPago>@FechaFinPagoPeriodoOriginal AND General=1 AND IDTipoNomina=@IDTipoNomina
        ORDER BY FechaInicioPago ASC

    END
    ELSE
    BEGIN
        SELECT TOP 1 *
        FROM Nomina.tblCatPeriodos
        WHERE FechaFinPago<@FechaIniPagoPeriodoOriginal AND General=1 AND IDTipoNomina=@IDTipoNomina
        ORDER BY FechaInicioPago DESC
    END
    
    -- exec [Utilerias].[spBuscarPeriodoProximo] 217,0

  
GO
