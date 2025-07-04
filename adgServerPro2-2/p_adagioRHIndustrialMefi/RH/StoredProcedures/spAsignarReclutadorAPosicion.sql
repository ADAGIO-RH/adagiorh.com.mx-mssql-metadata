USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spAsignarReclutadorAPosicion](
	@IDPosicion varchar(max),
	@IDReclutador int, --idempleado rh.tblempleadosMaster		
	@IDUsuario int
) as
	declare 
		@IDPlaza int
		,@IDPlazaAnterior int
		,@IDPosicionAnterior int
		,@ID_ESTATUS_POSICION_AUTORIZADA_DISPONIBLE int = 2
	;	
	BEGIN TRY
		BEGIN TRAN AsignarReclutadorAPosicion
			declare @tblIDSPosiciones as table(
                IDPosicion int
            );

            insert into @tblIDSPosiciones
            select  cast(item as int) from app.Split(@IDPosicion,',')

            UPDATE posiciones
                SET IDReclutador =@IDReclutador 
            from RH.tblCatPosiciones posiciones             
            where IDPosicion in (select IDPosicion from @tblIDSPosiciones)
                
            insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado,IDReclutador)
			select IDPosicion,@ID_ESTATUS_POSICION_AUTORIZADA_DISPONIBLE,@IDUsuario,null,@IDReclutador 
			from @tblIDSPosiciones

		COMMIT TRANSACTION AsignarReclutadorAPosicion
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION; 
		DECLARE @MESSAGE VARCHAR(max) =  ERROR_MESSAGE(),
			@SEVERITY VARCHAR(max) =  ERROR_SEVERITY(),
			@STATE VARCHAR(max) =  ERROR_STATE();
            
		RAISERROR(  
			@MESSAGE
			,@SEVERITY
			,@STATE 
		);
        
	END CATCH;
GO
