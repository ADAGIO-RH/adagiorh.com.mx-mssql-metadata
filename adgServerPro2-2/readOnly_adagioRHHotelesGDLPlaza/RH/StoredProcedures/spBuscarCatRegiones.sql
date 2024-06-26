USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatRegiones]
(
	@Region Varchar(50) = null
)
AS
BEGIN
	Select
	IDRegion
	,Codigo
	,Descripcion
	,CuentaContable
	,isnull(IDEmpleado,0) as IDEmpleado
	,JefeRegion
	,ROW_NUMBER()over(ORDER BY IDRegion)as ROWNUMBER
	From RH.tblCatRegiones
	where (Codigo like @Region+'%') OR(Descripcion like @Region+'%') OR(@Region is null)
	order by Descripcion ASC

END
GO
