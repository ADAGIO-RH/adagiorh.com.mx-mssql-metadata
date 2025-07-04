USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [RH].[spMoverColaboradorDePosicion](
	@IDPosicion int,
    @IDPosicionNueva int,
	@IDEmpleado int,
	@FechaAplicacion  date= null,
	@IDUsuario int
) as
	declare 
		@IDPlaza int,
        @IDPlazaNueva int,
		@ESTATUS_POSICION_AUTORIZADA_DISPONIBLE	INT = 2,
		@ESTATUS_POSICION_OCUPADA	INT = 3
	;

	IF(isnull(@FechaAplicacion,'') = '')
	BEGIN
		SET @FechaAplicacion = CAST(GETDATE() as date)
	END

	BEGIN TRY
		BEGIN TRAN AsignarColaboradorAPosicion
			select 
				@IDPlaza = IDPlaza
			from RH.tblCatPosiciones
			where IDPosicion = @IDPosicion
    
			update RH.tblCatPosiciones 
				set
					IDEmpleado = null
			where IDPosicion = @IDPosicion

			insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
			select @IDPosicion,@ESTATUS_POSICION_AUTORIZADA_DISPONIBLE,@IDUsuario,null

			EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza=@IDPlaza, @IDUsuario=@IDUsuario

			select 
				@IDPlazaNueva = IDPlaza
			from RH.tblCatPosiciones
			where IDPosicion = @IDPosicionNueva
    
			EXEC [Reclutamiento].[spAplicarHistorialesAEmpleado]  
				@IDPosicion = @IDPosicionNueva, 
				@IDEmpleado = @IDEmpleado, 
				@FechaAplicacion = @FechaAplicacion,  
				@IDUsuario = @IDUsuario

			update RH.tblCatPosiciones 
				set
					IDEmpleado = @IDEmpleado
			where IDPosicion = @IDPosicionNueva

			-- Estatus de Ocupada
			insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
			select @IDPosicionNueva,@ESTATUS_POSICION_OCUPADA,@IDUsuario,@IDEmpleado
	
			EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza = @IDPlazaNueva, @IDUsuario=@IDUsuario
			
			COMMIT TRANSACTION AsignarColaboradorAPosicion
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION; 
		DECLARE @MESSAGE VARCHAR(max) =  ERROR_MESSAGE(),
			@SEVERITY VARCHAR(max) =  ERROR_SEVERITY(),
			@STATE VARCHAR(max) =  ERROR_STATE();
            
		RAISERROR(  
			@MESSAGE
			,@SEVERITY
			,@STATE );
        
	END CATCH;
GO
