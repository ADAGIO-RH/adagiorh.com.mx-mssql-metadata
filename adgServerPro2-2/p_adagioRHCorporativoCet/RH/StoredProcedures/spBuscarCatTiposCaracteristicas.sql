USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc RH.spBuscarCatTiposCaracteristicas(
	@IDTipoCaracteristica int,
	@query varchar(20) = null,
	@SoloActivos bit = 0,
	@IDUsuario int
) as
	select
		IDTipoCaracteristica,
		TipoCaracteristica,
		Activo
	from RH.tblCatTiposCaracteristicas with (nolock)
	where (IDTipoCaracteristica = @IDTipoCaracteristica or isnull(@IDTipoCaracteristica, 0) = 0)
		and (Activo = case when ISNULL(@SoloActivos, 0) = 1 then 1 else Activo end)
GO
