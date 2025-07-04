USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spIUConfiguracionPlaza] (
	@IDConfiguracionPlaza int = 0,
	@IDPlaza int,
	@IDTipoConfiguracionPlaza [App].[SMName],
	@Valor varchar(max),
	@IDUsuario int
) as
	if (ISNULL(@IDConfiguracionPlaza, 0) = 0) 
	begin
		insert [RH].[tblConfiguracionesPlazas](IDPlaza, IDTipoConfiguracionPlaza, Valor)
		values (@IDPlaza, @IDTipoConfiguracionPlaza, @Valor)
	end else
	begin
		update [RH].[tblConfiguracionesPlazas]
			set
				Valor = @Valor
		where IDConfiguracionPlaza = @IDConfiguracionPlaza
	end
GO
