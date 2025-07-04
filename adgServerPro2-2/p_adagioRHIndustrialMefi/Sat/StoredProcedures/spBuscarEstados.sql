USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarEstados]-- null, 188
(
	@Estado Varchar(50) = null,
	@IDPais int = 151
)
AS
BEGIN
	select 
		IDEstado
		,UPPER(Codigo) AS Codigo
		,UPPER(NombreEstado) AS NombreEstado
		,@IDPais as IDPais 
	From [Sat].[tblCatEstados]
	where (IDPais = @IDPais OR IDEstado = 96
		or @IDPais is null 
		OR @IDPais = 0) 
	and ((NombreEstado like @Estado +'%') 
		OR (Codigo like @Estado+'%')  
		OR (@Estado is null)) 	
END
GO
