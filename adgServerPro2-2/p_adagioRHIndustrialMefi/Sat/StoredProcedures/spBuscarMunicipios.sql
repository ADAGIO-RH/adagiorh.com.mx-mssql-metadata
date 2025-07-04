USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarMunicipios]
(
	@Municipio Varchar(50) = null,
	@IDEstado int = null
)
AS
BEGIN
	select 
		IDMunicipio
		,UPPER(Codigo) AS Codigo
		,IDEstado
		,UPPER(Descripcion) AS Descripcion 
	From [Sat].[tblCatMunicipios]
	where ((IDEstado = @IDEstado) or (@IDEstado is null) or (@IDEstado = 0))
	and (((Descripcion like @Municipio +'%') 
		OR (Codigo like @Municipio+'%')  
		OR (@Municipio is null)) or @Municipio is null)	
		order by Descripcion asc
END
GO
