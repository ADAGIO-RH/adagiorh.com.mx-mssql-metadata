USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [RH].[spBuscarPosicionActualEmpleado](
	@IDEmpleado int,
	@IDUsuario int
) as

    declare @IDPosicion INT
    
	SELECT 
		IDPosicion
	FROM RH.tblCatPosiciones
	where IDEmpleado = @IDEmpleado
GO
