USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatEstadosCiviles]
(
	@EstadoCivil Varchar(50) = null
)
AS
BEGIN
	SELECT 
	IDEstadoCivil
	,Codigo
	,Descripcion 
	FROM RH.tblCatEstadosCiviles
	WHERE (Codigo LIKE @EstadoCivil+'%') OR(Descripcion LIKE @EstadoCivil+'%') OR (@EstadoCivil IS NULL)
END
GO
