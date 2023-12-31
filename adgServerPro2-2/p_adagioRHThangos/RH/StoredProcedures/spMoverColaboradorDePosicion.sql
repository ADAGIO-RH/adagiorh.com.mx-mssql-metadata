USE [p_adagioRHThangos]
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
        @IDPlazaNueva int
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

			-- Estatus de Ocupada
			insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
			select @IDPosicion,2,@IDUsuario,null

			EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza, @IDUsuario

			select 
				@IDPlazaNueva = IDPlaza
			from RH.tblCatPosiciones
			where IDPosicion = @IDPosicionNueva
    
			EXEC [Reclutamiento].[spAplicarHistorialesAEmpleado]  
				@IDPosicion = @IDPosicionNueva, 
				@IDEmpleado = @IDEmpleado, 
				--@SueldoAsignado = @SueldoAsignado, 
				@FechaAplicacion = @FechaAplicacion,  
				@IDUsuario = @IDUsuario

			update RH.tblCatPosiciones 
				set
					IDEmpleado = @IDEmpleado
			where IDPosicion = @IDPosicionNueva

			-- Estatus de Ocupada
			insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
			select @IDPosicionNueva,3,@IDUsuario,@IDEmpleado

	
			EXEC [RH].[spActualizarTotalesPosiciones] @IDPlazaNueva, @IDUsuario
			
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
