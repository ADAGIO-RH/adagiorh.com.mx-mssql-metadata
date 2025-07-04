USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spEnrutamiento_AutorizacionPlaza](	
    @dtFiltros Nomina.dtFiltrosRH readonly,
	@IDUsuario int
    
) as
    	    
    declare  @IDPlaza int;
    declare  @IDEstatus int;

    SET @IDPlaza = cast((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDReferencia'),',')) as int)       
    
    select @IDEstatus=s.IDCatalogoGeneral From app.tblCatalogosGenerales s where IDTipoCatalogo=4 and Catalogo='Autorizada';
                
	insert RH.tblEstatusPlazas(IDPlaza,IDEstatus,IDUsuario)
	values(@IDPlaza, @IDEstatus, @IDUsuario)


    declare @DisponibleDesde date 
    declare @DisponibleHasta date 
    declare @Temporal bit 
    declare @CantidadPosiciones INT 
    
    select 
        @DisponibleDesde= p.SolicitudDisponibleDesde,
        @DisponibleHasta= p.SolicitudDisponibleHasta,
        @Temporal = p.SolicitudIsTemporal,
        @CantidadPosiciones= p.SolicitudNumeroPosiciones    
    From  rh.tblSolicitudPosiciones  p
    where p.IDPlaza=@IDPlaza and p.IsActive=1

    declare @IDSolicitudPosiciones INT;

    select @IDSolicitudPosiciones=IDSolicitudPosiciones from rh.tblSolicitudPosiciones
    where IsActive=1 and IDPlaza=@IDPlaza

    update rh.tblSolicitudPosiciones set IsActive=0  where IDSolicitudPosiciones=@IDSolicitudPosiciones
    
    insert into rh.tblEstatusSolicitudPosiciones( IDSolicitudPosiciones,IDEstatus,IDUsuario,FechaReg)
    values (@IDSolicitudPosiciones,@IDEstatus,@IDUsuario,getdate())
	

    exec [RH].[spSolicitarNuevasPosiciones] 
        @IDPlaza=@IDPlaza,
        @DisponibleDesde=@DisponibleDesde ,
        @DisponibleHasta=@DisponibleHasta,
        @CantidadPosiciones=@CantidadPosiciones,
        @Temporal=@Temporal,
        @IDUsuario=@IDUsuario,
        @IDEstatusPosicion=@IDEstatus
GO
