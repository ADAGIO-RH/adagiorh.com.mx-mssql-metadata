USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spSolicitarNuevaPlaza](
	@IDPlaza int,
	@IDUsuario int
) as

	declare 
		@IDTipoCatalogoEstatusPlazas int = 4
	;

	--Estatus de plazas
	-- 1 - 'Pendiente de autorización'
	-- 2 - 'Autorizada'				
	-- 3 - 'Cancelada'				
	-- 4 - 'No autorizada'			

	insert RH.tblEstatusPlazas(IDPlaza,IDEstatus,IDUsuario)
	values(@IDPlaza, 1, @IDUsuario)

	-- Iniciar proceso de autorización
	exec [RH].[spIAprobadoresPlazas] @IDPlaza=@IDPlaza, @IDUsuario=@IDUsuario
GO
