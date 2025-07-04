USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarLocalidades]
(
	@Localidad Varchar(50) = null,
	@IDEstado int = null
)
AS
BEGIN
	select 
		IDLocalidad
		,UPPER(Codigo) AS Codigo
		,IDEstado
		,UPPER(Descripcion) AS Descripcion 
	From [Sat].[tblCatLocalidades]
	where (IDEstado = @IDEstado) 
	and ((Descripcion like @Localidad +'%') 
		OR (Codigo like @Localidad+'%')  
		OR (@Localidad is null)) 	
END
GO
