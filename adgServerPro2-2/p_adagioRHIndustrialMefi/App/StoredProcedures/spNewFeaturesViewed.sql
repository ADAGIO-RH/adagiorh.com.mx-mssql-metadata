USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc App.spNewFeaturesViewed(
	@IDFeature int, 
	@IDUsuario int
) as

	if not exists(select top 1 1 
					from App.tblNewFeaturesViews
					where IDFeature = @IDFeature and IDUsuario = @IDUsuario)
	begin
		insert App.tblNewFeaturesViews(IDFeature, IDUsuario, FechaReg)
		values (@IDFeature, @IDUsuario, getdate())
	end
GO
