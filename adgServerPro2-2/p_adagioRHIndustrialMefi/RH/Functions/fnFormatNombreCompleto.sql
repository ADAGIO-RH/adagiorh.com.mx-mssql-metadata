USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ANEUDY ABREU
-- Create date: 15-01-2024
-- Description:	Genera el nombre completo de un colaborador
-- =============================================
CREATE FUNCTION RH.fnFormatNombreCompleto(
	 @Nombre		varchar(50)
	,@SegundoNombre	varchar(50)
	,@Paterno		varchar(50)
	,@Materno		varchar(50)
)
RETURNS varchar(200)
AS
BEGIN	
	RETURN UPPER(TRIM(COALESCE(@Paterno,''))+' '+ TRIM(CASE WHEN ISNULL(@Materno,'') <> '' THEN ' '+COALESCE(@Materno,'') ELSE '' END)  +' '+TRIM(COALESCE(@Nombre,''))+ CASE WHEN TRIM(ISNULL(@SegundoNombre,'')) <> '' THEN ' '+TRIM(COALESCE(@SegundoNombre,'')) ELSE '' END) 
END
GO
