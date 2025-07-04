USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Justin Davila
-- Create date: 2023-12-06
-- Description:	nos genera el consecutivo de la etiqueta de un determinado tipo de articulo
-- =============================================
CREATE FUNCTION [ControlEquipos].[fnGetCodigoTrazable](
	@IDTipoArticulo int,
    @Incrementable int  =0
)
RETURNS VARCHAR(100)
AS
BEGIN
		DECLARE @PrefijoEtiqueta VARCHAR(100)
			, @LongitudEtiqueta INT
			, @SiguienteNumero INT
			, @CodigoTrazable VARCHAR(100);

	-- Obtener el prefijo y la longitud de trazabilidad
	SELECT @PrefijoEtiqueta = [PrefijoEtiqueta],
		   @LongitudEtiqueta = [LongitudEtiqueta]
	FROM [ControlEquipos].[tblCatTiposArticulos]
	WHERE [IDTipoArticulo] = @IDTipoArticulo;

	-- Obtener el máximo CodigoTrazable con el prefijo actual
	SELECT @CodigoTrazable = MAX(CAST(REPLACE(Etiqueta, @PrefijoEtiqueta, '') AS INT))
	FROM [ControlEquipos].[tblDetalleArticulos]
	WHERE Etiqueta LIKE @PrefijoEtiqueta+'%';
	
	SET @SiguienteNumero = ISNULL(@CodigoTrazable, 0) + 1 +@Incrementable;
	
	-- Calcular la cantidad de ceros a incluir
	DECLARE @CantidadCeros INT;
	SET @CantidadCeros = CASE
							WHEN @SiguienteNumero >= POWER(10, @LongitudEtiqueta - LEN(@PrefijoEtiqueta))
								THEN 0
							ELSE @LongitudEtiqueta - LEN(@PrefijoEtiqueta) - LEN(CAST(@SiguienteNumero AS VARCHAR))
						END;

	-- Generar el CodigoTrazable final
	SET @CodigoTrazable = @PrefijoEtiqueta + REPLICATE('0', @CantidadCeros) + CAST(@SiguienteNumero AS VARCHAR);
	return @CodigoTrazable;	
END
GO
