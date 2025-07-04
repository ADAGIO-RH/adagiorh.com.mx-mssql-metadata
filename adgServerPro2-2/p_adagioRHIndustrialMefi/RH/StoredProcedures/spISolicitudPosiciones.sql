USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spISolicitudPosiciones](
	@IDPlaza int = 0,
	@IDUsuario int,
	@SolicitudNumeroPosiciones  int,
	@SolicitudDisponibleDesde date=null,
	@SolicitudDisponibleHasta date=null,
	@SolicitudIsTemporal bit
) as

    DECLARE @HasSolicitudPosicionVigente int,
		@EjecutarRutas bit;

	select @EjecutarRutas = cast( valor as bit) 
	from app.tblConfiguracionesGenerales with(nolock)
	where IDConfiguracion = 'EjecutarRutas'
 

    select @HasSolicitudPosicionVigente= count(*) from rh.tblSolicitudPosiciones where IsActive =1 AND IDPlaza=@IDPlaza

    if @HasSolicitudPosicionVigente = 0 
    BEGIN 

        
        insert into rh.tblSolicitudPosiciones (IDPlaza,FechaReg,SolicitudDisponibleDesde,SolicitudDisponibleHasta,SolicitudIsTemporal,SolicitudNumeroPosiciones,IsActive,IDUsuario)
        values (@IDPlaza,getdate(),@SolicitudDisponibleDesde,@SolicitudDisponibleHasta,@SolicitudIsTemporal,@SolicitudNumeroPosiciones,@EjecutarRutas,@IDUsuario)

        declare @IDSolicitudPosiciones int 

        set @IDSolicitudPosiciones=@@IDENTITY
		
		if(@EjecutarRutas = 1)
		BEGIN
            insert into rh.tblEstatusSolicitudPosiciones (IDSolicitudPosiciones,FechaReg,IDEstatus,IDUsuario)
            values (@IDSolicitudPosiciones,GETDATE(),1,@IDUsuario)

            declare @EstatusPlaza  int ,
                    @IDCliente int 
            
            select @IDCliente = IDCliente FROM RH.tblCatPlazas where IDPlaza=@IDPlaza
            if exists( SELECT * From [RH].[tblCatPlazas]  s inner join  rh.tblEstatusPlazas ss on ss.IDPlaza=s.IDPlaza where IDEstatus=2 and s.IDPlaza=@IDPlaza)
            BEGIN
                EXEC [Enrutamiento].[spCrearUnidadProceso]
                    @IDCatTipoProceso = 2 ,--AUTORIZACION DE POSICIONES
                    @IDCliente = @IDCliente,
                    @IDReferencia = @IDSolicitudPosiciones,
                    @IDUsuario = @IDUsuario
                
            END ELSE
            BEGIN 
                if( not exists(select * From Enrutamiento.tblUnidadProceso where IDReferencia=@IDPlaza and IDEstatus in(1,6)))
                begin
                    EXEC [Enrutamiento].[spCrearUnidadProceso]
                        @IDCatTipoProceso = 1 ,--CREACION DE PLAZAS Y AUTORIZACION DE SOLICITUD DE POSICIONES
                        @IDCliente = @IDCliente,
                        @IDReferencia = @IDPlaza,
                        @IDUsuario = @IDUsuario    
                end
                
            END 
        END ELSE
		BEGIN
			insert into rh.tblEstatusSolicitudPosiciones (IDSolicitudPosiciones,FechaReg,IDEstatus,IDUsuario)
			values (@IDSolicitudPosiciones,GETDATE(),2,@IDUsuario) 

			
			exec [RH].[spSolicitarNuevasPosiciones] 
				@IDPlaza=@IDPlaza,
				@DisponibleDesde=@SolicitudDisponibleDesde ,
				@DisponibleHasta=@SolicitudDisponibleHasta,
				@CantidadPosiciones=@SolicitudNumeroPosiciones,
				@Temporal=@SolicitudIsTemporal,
				@IDUsuario=@IDUsuario,
				@IDEstatusPosicion=2

		END
    END ELSE
    BEGIN 
    	raiserror('No se puede generar una nueva solicitud para posiciones ya que actualmente se encuentra una solicitud de posiciones vigente.',16,1);
		return;
    END
GO
