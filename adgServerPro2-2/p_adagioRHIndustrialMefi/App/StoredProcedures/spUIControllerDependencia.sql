USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE App.spUIControllerDependencia
(
	@IDControllerParent int,
	@IDControllerChild int,
	@IDTipoPermiso nvarchar(20) 
)
AS
BEGIN

	if exists( select top 1 1 
				from app.TblControllerDependencias 
				where IDControllerParent = @IDControllerParent
				and IDControllerChild = @IDControllerChild
			)
	BEGIN
		RAISERROR('Esta combinacion ya existe en el catalogo de dependencias',16,1);
		RETURN;
	END

	insert into app.TblControllerDependencias(IDControllerParent,IDControllerChild,IDTipoPermiso)
	values(@IDControllerParent,@IDControllerChild,@IDTipoPermiso)

	Select 
	CD.IDControllerParent
	,c1.Nombre ControllerParent
	,CD.IDControllerChild
	,c2.Nombre ControllerChild
	,cd.IDTipoPermiso
	,p.Descripcion TipoPermiso
from app.TblControllerDependencias CD
	inner join App.tblCatControllers c1
		on CD.IDControllerParent = c1.IDController
	inner join App.tblCatControllers c2
		on cd.IDControllerChild = c2.IDController
	inner join app.tblCatTipoPermiso p
		on cd.IDTipoPermiso = p.IDTipoPermiso
 WHERE CD.IDControllerParent = @IDControllerParent
	and CD.IDControllerChild = @IDControllerChild

END
GO
