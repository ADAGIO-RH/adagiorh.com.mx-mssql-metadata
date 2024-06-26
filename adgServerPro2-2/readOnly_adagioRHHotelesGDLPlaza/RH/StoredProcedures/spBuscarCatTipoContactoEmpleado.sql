USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [RH].[spBuscarCatTipoContactoEmpleado](
    @IDTipoContacto int = 0
) as
    select 
		IDTipoContacto
		,Descripcion
		,Mask
		,CssClassIcon
		,ROW_NUMBER()over(ORDER BY IDTipoContacto)as ROWNUMBER 
    from [RH].[tblCatTipoContactoEmpleado] with (nolock)
    where (IDTipoContacto = @IDTipoContacto or @IDTipoContacto = 0)
    order by Descripcion
GO
