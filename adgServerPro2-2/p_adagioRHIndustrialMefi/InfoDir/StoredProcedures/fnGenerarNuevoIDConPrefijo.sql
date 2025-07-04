USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Generar un nuevo identificador con un prefijo específico para cualquier tabla. 
					  Este identificador se incrementará automáticamente, combinando un número secuencial con un prefijo definido, para crear un sistema de IDs auto-incrementales personalizado.

** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-08-22
** Paremetros		: @Prefijo		Es el número que se añade al principio de un ID.
**					: @Tabla		Nombre de tabla.
**					: @ColumnaID	Nombre de columna de donde obtendremos el ID.
**					: @NuevoID		Parámetro de salida que obtiene el nuevo ID con prefijo personalizado.
**					: @IDUsuario	Identificador del usuario.
** IDAzure			: 

** DataTypes Relacionados:
** Reglas de Negocio:

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROCEDURE [InfoDir].[fnGenerarNuevoIDConPrefijo]
    @Prefijo		INT
	, @Tabla		NVARCHAR(128)
	, @ColumnaID	NVARCHAR(128)
	, @NuevoID		VARCHAR(20) OUTPUT
	, @IDUsuario	INT	
AS
BEGIN

    DECLARE 
		@PrefijoStr VARCHAR(10) = CAST(@Prefijo AS VARCHAR(10))
		, @MaxID VARCHAR(20)
		, @NumeroParte INT
		, @SQL NVARCHAR(MAX)


    -- CREAR LA CONSULTA SQL DINÁMICA
	SET @SQL = N'
					SELECT @MaxID = MAX(' + CAST(@ColumnaID AS VARCHAR(100)) + ')
					FROM ' + CAST(@Tabla AS VARCHAR(100)) + '
					WHERE ' + CAST(@ColumnaID AS VARCHAR(100)) + ' LIKE @PrefijoStr + ''%'';
				';


    -- EJECUTAR LA CONSULTA SQL DINÁMICA, EXTRAE EL @MaxID
    EXEC sp_executesql @SQL, 
                        N'@PrefijoStr VARCHAR(10), @MaxID VARCHAR(20) OUTPUT',
                        @PrefijoStr, 
                        @MaxID OUTPUT;


    -- SI NO HAY REGISTROS, INICIAR LA SECUENCIA EN @Prefijo + 1
    IF @MaxID IS NULL
    BEGIN
        SET @NuevoID = @Prefijo * 10 + 1;
    END
    ELSE
		BEGIN
			-- EXTRAE LA PARTE NUMÉRICA DEL ID DESPUES DEL PREFIJO
			SET @NumeroParte = CAST(SUBSTRING(@MaxID, LEN(@PrefijoStr) + 1, LEN(@MaxID)) AS INT);
                    
			-- AUMENTAR EL VALOR EN 1
			SET @NumeroParte = @NumeroParte + 1;
                    
			-- COMBINAR EL PREFIJO CON LA NUEVA PARTE NUMÉRICA
			SET @NuevoID = CAST(@Prefijo AS VARCHAR(10)) + CAST(@NumeroParte AS VARCHAR(10));
		END

END
GO
