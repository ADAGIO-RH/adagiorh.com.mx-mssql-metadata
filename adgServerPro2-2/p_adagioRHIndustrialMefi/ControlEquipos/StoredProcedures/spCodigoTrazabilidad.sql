USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Sirve para buscar el siguiente Código de Trazabilidad
** Autor			: Emmanuel Contreras
** Email			: emmanuel.contreras@adagio.com.mx
** FechaCreacion	: 2023-05-22
** Paremetros		:    
	@IDTipoArticulo INT
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
EXEC [ControlEquipos].[spCodigoTrazabilidad]  @IDTipoArticulo  = 3
***************************************************************************************************/
CREATE PROCEDURE [ControlEquipos].[spCodigoTrazabilidad] 
	(
		@IDTipoArticulo INT,
		@Etiqueta VARCHAR(100) OUTPUT
	)
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
	
	SET @SiguienteNumero = ISNULL(@CodigoTrazable, 0) + 1;
	
	-- Calcular la cantidad de ceros a incluir
	DECLARE @CantidadCeros INT;
	SET @CantidadCeros = CASE
							WHEN @SiguienteNumero >= POWER(10, @LongitudEtiqueta - LEN(@PrefijoEtiqueta))
								THEN 0
							ELSE @LongitudEtiqueta - LEN(@PrefijoEtiqueta) - LEN(CAST(@SiguienteNumero AS VARCHAR))
						END;

	-- Generar el CodigoTrazable final
	SET @CodigoTrazable = @PrefijoEtiqueta + REPLICATE('0', @CantidadCeros) + CAST(@SiguienteNumero AS VARCHAR);
	SET @Etiqueta = @CodigoTrazable;
	--SELECT @CodigoTrazable;
END
GO
