USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spEnrutamiento_DetenerxRechazoPlaza](	
    @dtFiltros Nomina.dtFiltrosRH readonly,
	@IDUsuario int    
) as
    	    
    declare  @IDPlaza int;
    declare  @IDEstatus int;
    DECLARE @IDSolicitudPosiciones int

    SET @IDPlaza = cast((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDReferencia'),',')) as int)       
    
    select @IDEstatus=s.IDCatalogoGeneral From app.tblCatalogosGenerales s where IDTipoCatalogo=4 and Catalogo='No autorizada';
    
                
	insert RH.tblEstatusPlazas(IDPlaza,IDEstatus,IDUsuario)
	values(@IDPlaza, @IDEstatus, @IDUsuario)


    select @IDSolicitudPosiciones= IDSolicitudPosiciones from rh.tblSolicitudPosiciones
    where IDPlaza=@IDPlaza and IsActive=1


    update rh.tblSolicitudPosiciones set IsActive=0  where IDSolicitudPosiciones=@IDSolicitudPosiciones
    
    insert into rh.tblEstatusSolicitudPosiciones( IDSolicitudPosiciones,IDEstatus,IDUsuario,FechaReg)
    values (@IDSolicitudPosiciones,@IDEstatus,@IDUsuario,getdate())
GO
