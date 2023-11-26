USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spBuscarCatFraccion]
(
	@Fraccion Varchar(50) = null
)
AS
BEGIN
	select * from [IMSS].[tblCatFraccion]
	WHERE ((Codigo like @Fraccion+'%') OR (Descripcion like @Fraccion+'%')OR(@Fraccion is null))
END
GO
