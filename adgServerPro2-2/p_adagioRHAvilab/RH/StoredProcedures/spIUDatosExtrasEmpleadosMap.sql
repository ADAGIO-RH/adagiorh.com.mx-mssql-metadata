USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUDatosExtrasEmpleadosMap]
(
    @dtDatosExtras [RH].[dtDatosExtrasImportacionMap] READONLY,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tempMessages TABLE(
        ID INT,
        [Message] VARCHAR(500),
        Valid BIT
    )

    -- Define validation messages
    INSERT @tempMessages(ID, [Message], Valid)
    VALUES
        (1, 'Datos correctos', 1),
        (2, 'La clave del empleado no existe', 0),
        (3, 'El dato extra no existe', 0),
        (4, 'El valor no corresponde al tipo de dato', 0),
        (5, 'El valor será actualizado', 1)  -- New message for updates

    -- Perform validation and return results
    SELECT 
        info.*,
        (SELECT m.[Message] as Message, CAST(m.Valid as bit) as Valid
         FROM @tempMessages m 
         WHERE ID IN (SELECT ITEM FROM app.split(info.IDMensaje,',')) 
         FOR JSON PATH) as Msg,
        CAST(
            CASE WHEN EXISTS (
                SELECT m.[Valid]
                FROM @tempMessages m 
                WHERE ID IN (SELECT ITEM FROM app.split(info.IDMensaje,','))
                AND Valid = 0
            ) THEN 0 ELSE 1 END as bit
        ) as Valid
    FROM (
        SELECT   
            ISNULL((SELECT TOP 1 e.IDEmpleado 
                    FROM RH.tblEmpleadosMaster e 
                    WHERE e.ClaveEmpleado = dt.ClaveEmpleado), 0) as [IDEmpleado],
            ISNULL((SELECT TOP 1 em.NOMBRECOMPLETO 
                    FROM RH.tblEmpleadosMaster em                    
                    WHERE em.ClaveEmpleado = dt.ClaveEmpleado), '') as NombreCompleto,
            dt.ClaveEmpleado,
            dt.NombreDatoExtra,
            dt.Valor,
            ISNULL((SELECT TOP 1 d.IDDatoExtra 
                    FROM RH.tblcatDatosExtra d 
                    WHERE d.Nombre = dt.NombreDatoExtra), 0) as IDDatoExtra,
            ISNULL((SELECT TOP 1 dee.IDDatoExtraEmpleado
                    FROM RH.tblDatosExtraEmpleados dee
                    INNER JOIN RH.tblcatDatosExtra d ON d.IDDatoExtra = dee.IDDatoExtra
                    INNER JOIN RH.tblEmpleados e ON e.IDEmpleado = dee.IDEmpleado
                    WHERE e.ClaveEmpleado = dt.ClaveEmpleado 
                    AND d.Nombre = dt.NombreDatoExtra), 0) as IDDatoExtraEmpleado,
            IDMensaje = 
                CASE WHEN ISNULL((SELECT TOP 1 e.IDEmpleado 
                                FROM RH.tblEmpleadosMaster e 
                                WHERE e.ClaveEmpleado = dt.ClaveEmpleado), 0) = 0 
                     THEN '2,' ELSE '' END +
                CASE WHEN ISNULL((SELECT TOP 1 d.IDDatoExtra 
                                FROM RH.tblcatDatosExtra d 
                                WHERE d.Nombre = dt.NombreDatoExtra), 0) = 0 
                     THEN '3,' ELSE '' END +
                CASE WHEN NOT EXISTS (
                    SELECT 1 
                    FROM RH.tblcatDatosExtra d 
                    WHERE d.Nombre = dt.NombreDatoExtra
                    AND (
                        (d.TipoDato IN ('VARCHAR', 'NVARCHAR', 'CHAR', 'TEXT', 'string') AND ISNULL(dt.Valor, '') <> '')
                        OR (d.TipoDato IN ('INT', 'BIGINT', 'SMALLINT', 'TINYINT') AND ISNUMERIC(dt.Valor) = 1)
                        OR (d.TipoDato IN ('DECIMAL', 'FLOAT', 'REAL') AND ISNUMERIC(dt.Valor) = 1)
                        OR (d.TipoDato IN ('bool','BIT') AND dt.Valor IN ('0','1','true','false','TRUE','FALSE'))
                        OR (d.TipoDato = 'DATE' AND ISDATE(dt.Valor) = 1)
                    )
                ) THEN '4,' ELSE '' END +
                -- Add update message if record exists
                CASE WHEN EXISTS (
                    SELECT 1
                    FROM RH.tblDatosExtraEmpleados dee
                    INNER JOIN RH.tblcatDatosExtra d ON d.IDDatoExtra = dee.IDDatoExtra
                    INNER JOIN RH.tblEmpleados e ON e.IDEmpleado = dee.IDEmpleado
                    WHERE e.ClaveEmpleado = dt.ClaveEmpleado 
                    AND d.Nombre = dt.NombreDatoExtra
                ) THEN '5,' ELSE '' END
        FROM @dtDatosExtras dt
        WHERE ISNULL(dt.ClaveEmpleado,'') <> ''
    ) info 
    ORDER BY info.ClaveEmpleado
END
GO
