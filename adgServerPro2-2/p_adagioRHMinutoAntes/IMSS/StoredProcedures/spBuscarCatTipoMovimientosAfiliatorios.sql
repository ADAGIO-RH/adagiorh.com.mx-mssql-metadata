USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [IMSS].[spBuscarCatTipoMovimientosAfiliatorios]
as
    select *
    from [IMSS].[tblCatTipoMovimientos] with (nolock)
    order by Prioridad
GO
