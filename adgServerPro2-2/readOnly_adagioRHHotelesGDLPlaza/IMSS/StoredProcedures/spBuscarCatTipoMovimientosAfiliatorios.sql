USE [readOnly_adagioRHHotelesGDLPlaza]
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
