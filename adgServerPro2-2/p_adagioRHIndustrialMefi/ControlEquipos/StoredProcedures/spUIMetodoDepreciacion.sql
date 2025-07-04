USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [ControlEquipos].[spUIMetodoDepreciacion]
    @IDMetodoDepreciacion INT,
    @Nombre VARCHAR(50),
    @Descripcion VARCHAR(100),
    @FactorDepreciacion DECIMAL(10, 2),
    @PorcentajeMinimo DECIMAL(5, 2),
	@IDUsuario INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el registro ya existe en la tabla
    IF EXISTS (SELECT 1 FROM ControlEquipos.tblMetodoDepreciacion WHERE IDMetodoDepreciacion = @IDMetodoDepreciacion)
    BEGIN
        -- Actualizar el registro existente
        UPDATE ControlEquipos.tblMetodoDepreciacion
        SET Nombre = UPPER(@Nombre),
            Descripcion = UPPER(@Descripcion),
            FactorDepreciacion = @FactorDepreciacion,
            PorcentajeMinimo = @PorcentajeMinimo
        WHERE IDMetodoDepreciacion = @IDMetodoDepreciacion;
    END
    ELSE
    BEGIN
        -- Insertar un nuevo registro
        INSERT INTO ControlEquipos.tblMetodoDepreciacion (Nombre, Descripcion, FactorDepreciacion, PorcentajeMinimo)
        VALUES (UPPER(@Nombre), UPPER(@Descripcion), @FactorDepreciacion, @PorcentajeMinimo);

		SET @IDMetodoDepreciacion = SCOPE_IDENTITY();
    END

	EXEC [ControlEquipos].[spBuscarMetodoDepreciacion]@IDMetodoDepreciacion = @IDMetodoDepreciacion
END
GO
