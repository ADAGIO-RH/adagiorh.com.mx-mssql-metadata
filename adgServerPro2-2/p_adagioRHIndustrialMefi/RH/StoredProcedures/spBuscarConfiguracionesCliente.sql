USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RH].[spBuscarConfiguracionesCliente] --@IDCliente = 1
(  
    @IDCliente int = null,
    @IDTipoConfiguracionCliente varchar(255) = null,  
	@IDAplicacion NVarchar(100) = null
)  
as  
    select cg.IDTipoConfiguracionCliente  
		,cg.TipoConfiguracionCliente
		,cg.TipoDato
		,cg.IDAplicacion
		,tcg.Valor  
		,cg.Descripcion  
		,isnull(tcg.IDConfiguracionCliente,0) as IDConfiguracionCliente  
		,isnull(@IDCliente,0) as IDCliente  
		,cg.[Data]
    from  [RH].[tblCatTipoConfiguracionesCliente] cg  
		Left outer join RH.tblConfiguracionesCliente tcg with (nolock) on cg.IDTipoConfiguracionCliente = tcg.IDTipoConfiguracionCliente  
			and tcg.IDCliente = @IDCliente
    where ((cg.IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente) or (isnull(@IDTipoConfiguracionCliente,'') = ''))  
       --AND ((tcg.IDCliente = @IDCliente) OR (ISNULL(@IDCliente,0) = 0))  
       AND ((cg.IDAplicacion = @IDAplicacion) OR (ISNULL(@IDAplicacion,'') = ''))  
	order by cg.IDTipoConfiguracionCliente ASC
GO
