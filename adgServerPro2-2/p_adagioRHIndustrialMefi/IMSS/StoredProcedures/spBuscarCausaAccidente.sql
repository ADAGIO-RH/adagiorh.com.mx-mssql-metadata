USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Imss].[spBuscarCausaAccidente](
    @IDCausaAccidente int = 0
) as
    select IDCausaAccidente
	   ,Descripcion
	   ,Origen
    from [Imss].[tblCatCausasAccidentes]    
    where (IDCausaAccidente = @IDCausaAccidente) or (@IDCausaAccidente = 0)
GO
