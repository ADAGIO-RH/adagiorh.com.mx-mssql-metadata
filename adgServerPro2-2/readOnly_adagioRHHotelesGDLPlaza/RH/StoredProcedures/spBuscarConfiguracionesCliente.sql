USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RH].[spBuscarConfiguracionesCliente] --1
(  
    @IDCliente int,
    @IDTipoConfiguracionCliente varchar(255) = null  
)   
as  
    select cg.IDTipoConfiguracionCliente  
    ,tcg.Valor  
    ,cg.Descripcion  
    ,isnull(tcg.IDConfiguracionCliente,0) as IDConfiguracionCliente  
    ,isnull(@IDCliente,0) as IDCliente  
	,ROW_NUMBER()Over(Order by tcg.IDConfiguracionCliente asc) as ROWNUMBER 
    from  [RH].[tblCatTipoConfiguracionesCliente] cg  
	Left outer join RH.tblConfiguracionesCliente tcg with (nolock) 
		on cg.IDTipoConfiguracionCliente = tcg.IDTipoConfiguracionCliente  
		and tcg.IDCliente = @IDCliente
    where ((cg.IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente) or (@IDTipoConfiguracionCliente is null))  
      -- AND ((tcg.IDCliente = @IDCliente))  
order by cg.IDTipoConfiguracionCliente
GO
