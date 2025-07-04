USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [RH].[spIEstatusPosicion](
	@IDPosicion int,
	@IDEstatus int,
	@IDUsuario int
) as
	declare 
		@IDPlaza int
	;

	select @IDPlaza = IDPlaza
	from RH.tblCatPosiciones
	where IDPosicion = @IDPosicion
        		 	
	insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
	select @IDPosicion,@IDEstatus,@IDUsuario,null

    EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza=@IDPlaza, @IDUsuario=@IDUsuario
GO
