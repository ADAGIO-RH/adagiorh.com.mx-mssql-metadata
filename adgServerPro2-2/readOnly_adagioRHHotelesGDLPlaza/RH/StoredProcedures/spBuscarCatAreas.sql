USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatAreas](
	@IDArea int = 0,
	@Area Varchar(50) = null
)
AS
BEGIN
	SELECT 
		IDArea
		,Codigo
		,Descripcion
		,CuentaContable
		,isnull(IDEmpleado,0) as IDEmpleado
		,JefeArea 
	FROM RH.tblCatArea
	WHERE (IDArea = @IDArea or isnull(@IDArea, 0) = 0) 
	--and
	--	(Codigo LIKE @Area+'%') OR(Descripcion LIKE @Area+'%') OR (@Area IS NULL)
	order by RH.tblCatArea.Descripcion asc
END
GO
