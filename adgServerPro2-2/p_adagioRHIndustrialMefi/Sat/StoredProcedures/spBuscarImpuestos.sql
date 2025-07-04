USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarImpuestos]
(
	@Impuesto Varchar(10) = ''
)
AS
BEGIN
	IF(@Impuesto = '' or @Impuesto is null)
	BEGIN
		select 
			IDImpuesto
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
			,Retencion
			,Traslado
			,UPPER(LocalFederal) AS LocalFederal
		From [Sat].[tblCatImpuestos]
	END
	ELSE
	BEGIN
		select 
			IDImpuesto
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
			,Retencion
			,Traslado
			,UPPER(LocalFederal) AS LocalFederal 
		From [Sat].[tblCatImpuestos]
		where Descripcion like @Impuesto +'%'
			OR Codigo like @Impuesto+'%'
	END
END
GO
