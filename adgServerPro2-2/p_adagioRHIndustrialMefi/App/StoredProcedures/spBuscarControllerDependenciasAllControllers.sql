USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarControllerDependenciasAllControllers]
AS
BEGIN

Select 
	isnull(CC.IDController,0) as IDControllerParent
	,isnull(CC.Nombre,'') as  ControllerParent
	,isnull(CD.IDControllerChild,0) as IDControllerChild
	,isnull(CChild.Nombre,'') as ControllerChild
	,isnull(CD.IDTipoPermiso,'') as IDTipoPermiso
	,isnull(P.Descripcion,'') as TipoPermiso
from App.tblCatControllers CC
	left join app.TblControllerDependencias CD on CC.IDController = CD.IDControllerParent
	left join App.tblCatControllers CCParent on CD.IDControllerParent = CCParent.IDController
	left join App.tblCatControllers CChild on  CD.IDControllerChild = CChild.IDController
	left join app.tblCatTipoPermiso P on CD.IDTipoPermiso = P.IDTipoPermiso


END
GO
