USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spBuscarSolicitudPendiente](
	@IDPlaza int = 0,
    @IDSolicitudPosiciones int =0 ,
    @IDUsuario int=0

) as
    select 
        top 1 
        s.IDSolicitudPosiciones,
        s.IDPlaza,
        isnull(s.IDUsuario,0) AS IDUsuario,
        s.FechaReg,
        s.SolicitudDisponibleDesde,
        s.SolicitudDisponibleHasta,
        s.SolicitudIsTemporal,
        s.SolicitudNumeroPosiciones,
        cp.IDCatalogoGeneral as IDEstatus,
        cp.Catalogo as  Estatus,
        cp.configuracion as ConfiguracionEstatus,
        es.IDEstatusSolicitudPosiciones 
        
    
    From rh.tblSolicitudPosiciones s 
        inner join rh.tblEstatusSolicitudPosiciones es on s.IDSolicitudPosiciones=es.IDSolicitudPosiciones
        inner join App.tblCatalogosGenerales cp on cp.IDTipoCatalogo=7 and cp.IDCatalogoGeneral=es.IDEstatus
    where  (s.IDPlaza=@IDPlaza  or @IDPlaza=0) and (s.IDSolicitudPosiciones=@IDSolicitudPosiciones  or @IDSolicitudPosiciones=0)
        order by  es.FechaReg desc
GO
