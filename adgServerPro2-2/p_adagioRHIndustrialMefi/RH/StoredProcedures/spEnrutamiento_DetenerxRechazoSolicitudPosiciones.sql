USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spEnrutamiento_DetenerxRechazoSolicitudPosiciones](	
    @dtFiltros Nomina.dtFiltrosRH readonly,
	@IDUsuario int    
) as
    	    
    DECLARE  @IDPlaza int;
    DECLARE  @IDEstatus int;
    DECLARE @IDSolicitudPosiciones int

    SET @IDSolicitudPosiciones = cast((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDReferencia'),',')) as int)       
    
    select @IDEstatus=s.IDCatalogoGeneral From app.tblCatalogosGenerales s where IDTipoCatalogo=5 and Catalogo='No autorizada';
	
    select @IDPlaza=IDPlaza from rh.tblSolicitudPosiciones
    where IDSolicitudPosiciones=@IDSolicitudPosiciones


    update rh.tblSolicitudPosiciones set IsActive=0  where IDSolicitudPosiciones=@IDSolicitudPosiciones
    
    insert into rh.tblEstatusSolicitudPosiciones( IDSolicitudPosiciones,IDEstatus,IDUsuario,FechaReg)
    values (@IDSolicitudPosiciones,@IDEstatus,@IDUsuario,getdate())
GO
