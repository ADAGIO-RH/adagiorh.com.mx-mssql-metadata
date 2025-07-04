USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spBuscarSolicitudPosicion](
	@IDSolicitudPosiciones int = 0,
    @IDUsuario int =0
    
) as
    select  * 
    From rh.tblSolicitudPosiciones s         
    inner join rh.tblEstatusSolicitudPosiciones sp on sp.IDSolicitudPosiciones=s.IDSolicitudPosiciones
    where  s.IDSolicitudPosiciones= @IDSolicitudPosiciones
    order by sp.FechaReg desc
GO
