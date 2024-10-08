USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	EXEC [RH].[spAsignarColaboradorAPosicion]
		@IDPosicion = 61, 
		@IDEmpleado = 390, 
		@SueldoAsignado = 145, 
		@FechaAplicacion = '2022-05-06',  
		@IDUsuario = 1
*/

CREATE proc [RH].[spAsignarColaboradorAPosicion](
	@IDPosicion int,
	@IDEmpleado int,
	@SueldoAsignado decimal(18,2)=0,
	@FechaAplicacion date= null,
    @dtHistorial_a_Modificar [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
) as
	declare 
		@IDPlaza int
		,@IDPlazaAnterior int
		,@IDPosicionAnterior int
	;

	IF(isnull(@FechaAplicacion,'') = '')
	BEGIN
		SET @FechaAplicacion = CAST(GETDATE() as date)
	END

	BEGIN TRY
		BEGIN TRAN AsignarColaboradorAPosicion

            -- select 1/0 ; -- provocar excepcion

			select top 1
				@IDPosicionAnterior = IDPosicion,
				@IDPlazaAnterior = IDPlaza
			from RH.tblCatPosiciones with(nolock)
			where IDEmpleado = @IDEmpleado
     
			if(isnull(@IDPosicionAnterior,0) > 0)
			BEGIN
				update RH.tblCatPosiciones 
					set
						IDEmpleado = null
				where IDPosicion = @IDPosicionAnterior

				-- Estatus de libre
				insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
				select @IDPosicionAnterior,2,@IDUsuario,null

				EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza=@IDPlazaAnterior, @IDUsuario=@IDUsuario
                exec [RH].[spActualizarJefesEmpleadosSubordinados] @IDPosicion=@IDPosicionAnterior;
			END

			select 
				@IDPlaza = IDPlaza
			from RH.tblCatPosiciones with(nolock)
			where IDPosicion = @IDPosicion

			EXEC [Reclutamiento].[spAplicarHistorialesAEmpleado]  
				@IDPosicion = @IDPosicion, 
				@IDEmpleado = @IDEmpleado, 
				@SueldoAsignado = @SueldoAsignado, 
				@FechaAplicacion = @FechaAplicacion,  
				@IDUsuario = @IDUsuario,
                @dtHistorial_a_Modificar=@dtHistorial_a_Modificar

			update RH.tblCatPosiciones
				set
					IDEmpleado = @IDEmpleado
			where IDPosicion = @IDPosicion

			-- Estatus de Ocupada
			insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
			select @IDPosicion,3,@IDUsuario,@IDEmpleado

			EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza=@IDPlaza, @IDUsuario=@IDUsuario

            
            EXEC [RH].[spAsignarJefesEmpleadosOrganigramaIndividual] @IDPosicion=@IDPosicion
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
