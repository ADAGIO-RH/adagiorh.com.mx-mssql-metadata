USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarCatWizardItem]
as
	select *
	from [Evaluacion360].[tblCatWizardItem]
	order by Orden asc
GO
