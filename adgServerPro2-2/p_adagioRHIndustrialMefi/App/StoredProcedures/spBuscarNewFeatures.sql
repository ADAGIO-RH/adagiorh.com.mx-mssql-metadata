USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [App].[spBuscarNewFeatures](
	@IDFeature int, 
	@IDUsuario int
) as

	select
		nf.IDFeature,
		nf.[Name],
		nf.Active
	from App.tblNewFeatures nf
		left join App.tblNewFeaturesViews nfv on nfv.IDFeature = nf.IDFeature and nfv.IDUsuario = @IDUsuario
	where nf.IDFeature = @IDFeature 
		and nfv.IDNewFeatureView is null
		and nf.Active = 1
GO
