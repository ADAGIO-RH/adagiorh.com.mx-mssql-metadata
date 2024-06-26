USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarTiposContrato]
(
	@TipoContrato Varchar(50) = ''
)
AS
BEGIN
	IF(@TipoContrato = '' or @TipoContrato is null)
	BEGIN
		select 
			IDTipoContrato
			,UPPER(Codigo) as Codigo
			,UPPER(Descripcion)  as Descripcion
		From [Sat].[tblCatTiposContrato]
	END
	ELSE
	BEGIN
		select 
			IDTipoContrato
			,UPPER(Codigo) as Codigo
			,UPPER(Descripcion)  as Descripcion
		From [Sat].[tblCatTiposContrato]
		where Descripcion like @TipoContrato +'%'
			OR Codigo like @TipoContrato+'%'
	END
END
GO
