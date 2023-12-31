USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [RH].[spMoverColaboradorDePosicion](
	@IDPosicion int,
    @IDPosicionNueva int,
	@IDEmpleado int,
	@IDUsuario int
) as
	declare 
		@IDPlaza int,
        @IDPlazaNueva int
	;

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
    
	update RH.tblCatPosiciones 
        set
			IDEmpleado = @IDEmpleado
	where IDPosicion = @IDPosicionNueva

	-- Estatus de Ocupada
	insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
	select @IDPosicionNueva,3,@IDUsuario,@IDEmpleado

	
	EXEC [RH].[spActualizarTotalesPosiciones] @IDPlazaNueva, @IDUsuario
GO
