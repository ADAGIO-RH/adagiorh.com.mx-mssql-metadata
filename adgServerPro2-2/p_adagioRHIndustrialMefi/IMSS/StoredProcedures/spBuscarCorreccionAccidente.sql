USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Imss].[spBuscarCorreccionAccidente](
    @IDCorreccionAccidente int = 0
) as
    select IDCorreccionAccidente
	   ,Descripcion
	   ,Origen
    from [Imss].[tblCatCorreccionesAccidentes]    
    where (IDCorreccionAccidente = @IDCorreccionAccidente) or (@IDCorreccionAccidente = 0)
GO
