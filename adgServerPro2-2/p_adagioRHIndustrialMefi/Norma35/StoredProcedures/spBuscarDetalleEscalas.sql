USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Norma35].[spBuscarDetalleEscalas]
as
select 
	ce.IDCatEscala
	,ce.Descripcion
	,cde.IDCatDetalleEscala
	,cde.Nombre
	,cde.Valor
from [Norma35].[tblCatEscalas] ce with (nolock)
	join [Norma35].[tblCatDetalleEscala] cde with (nolock) on ce.IDCatEscala = cde.IDCatEscala
GO
