USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Nomina].[fnObtenerValorFiltro] (
	@dtFiltros Nomina.dtFiltrosRH READONLY, 
	@Catalogo VARCHAR(200), 
	@ValorDefault VARCHAR(MAX) = NULL
)
RETURNS VARCHAR(MAX)
WITH SCHEMABINDING
AS
BEGIN
  -- Usar ISNULL para manejar el caso de que no se encuentre el catálogo
  RETURN ISNULL(
    (
      SELECT TOP 1 [Value] 
      FROM @dtFiltros
      WHERE Catalogo = @Catalogo
    ), 
    @ValorDefault
  );
END;
GO
