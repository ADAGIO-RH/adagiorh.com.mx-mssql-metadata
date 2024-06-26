USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarPaises](
	@Pais Varchar(50) = null
)
AS
BEGIN
	select 
		IDPais
		,UPPER(Codigo) AS Codigo
		,UPPER(Descripcion) AS Descripcion
		,UPPER(FormatoCodigoPostal) AS FormatoCodigoPostal
		,UPPER(FormatoRegistroIdentidadTributaria) AS FormatoRegistroIdentidadTributaria
		,UPPER(Agrupaciones) AS Agrupaciones
	From [Sat].[tblCatPaises]
	where ((Descripcion like @Pais +'%') 
		OR (Codigo like @Pais+'%')  
		OR (@Pais is null)) 	
	order by isnull(Orden,9999), Descripcion
END
GO
