USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Utilerias].[GetInfoUsuarioEmpleadoFotoAvatar] (
    @IDEmpleado INT = 0,
    @IDUsuario INT = 0
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Result NVARCHAR(MAX);

    IF(ISNULL(@IDEmpleado,0)=0 AND ISNULL(@IDUsuario,0)<>0 )
    BEGIN
    SET @Result=(
        SELECT  CASE WHEN E.IDEmpleado IS NOT NULL 
                     THEN cast(1 as bit)  
                     ELSE cast(0 as bit)  
                END AS EsEmpleado
               ,CASE WHEN E.IDEmpleado IS NOT NULL 
                     THEN e.ClaveEmpleado  
                     ELSE cast(u.IDUsuario as varchar(100))
                END AS Clave
                ,CASE WHEN E.IDEmpleado IS NOT NULL 
                     THEN SUBSTRING(coalesce(e.Nombre, ''), 1, 1)+SUBSTRING(coalesce(e.Paterno, coalesce(e.Materno, '')), 1, 1)
                     ELSE SUBSTRING(coalesce(u.Nombre, ''), 1, 1)+SUBSTRING(coalesce(u.Apellido, ''), 1, 1)
                END AS Iniciales               
               ,CASE WHEN E.IDEmpleado IS NOT NULL 
                     THEN REPLACE(RTRIM(LTRIM(
				                        TRIM(COALESCE(e.Nombre,''))+ 
				                        CASE WHEN TRIM(ISNULL(e.SegundoNombre,'')) <> '' THEN ' '+TRIM(COALESCE(e.SegundoNombre,'')) ELSE '' END +' '+
				                        TRIM(COALESCE(e.Paterno,''))+' '+
				                        TRIM(CASE WHEN ISNULL(e.Materno,'') <> '' THEN ' '+COALESCE(e.Materno,'') ELSE '' END)
				                        )),'  ',' ')
                     ELSE COALESCE(u.Nombre, '') + ' ' + COALESCE(u.Apellido, '') 
                END AS NombreCompleto               
               ,CASE WHEN fe.IDEmpleado IS NULL 
                     THEN cast(0 as bit) 
                     ELSE cast(1 as bit)
                END AS ExisteFotoColaborador 
              ,CASE WHEN E.IDEmpleado IS NOT NULL 
                     THEN E.IDEmpleado  
                     ELSE U.IDUsuario  
                END AS ID
        FROM Seguridad.tblUsuarios U
            LEFT JOIN RH.tblEmpleados E
                ON U.IDEmpleado=E.IDEmpleado
            LEFT JOIN [RH].[tblFotosEmpleados] FE with (nolock) 
                ON FE.IDEmpleado = E.IDEmpleado  
        WHERE U.IDUsuario=@IDUsuario
        for json path, without_array_wrapper
    )        
    END
    ELSE IF(ISNULL(@IDEmpleado,0)<>0 AND ISNULL(@IDUsuario,0)=0 )
    BEGIN
    SET @Result=(
        SELECT  cast(1 as bit)  AS EsEmpleado
               ,E.ClaveEmpleado as Clave
               ,SUBSTRING(coalesce(e.Nombre, ''), 1, 1)+SUBSTRING(coalesce(e.Paterno, coalesce(e.Materno, '')), 1, 1) AS Iniciales               
               ,REPLACE(RTRIM(LTRIM(
				                        TRIM(COALESCE(e.Nombre,''))+ 
				                        CASE WHEN TRIM(ISNULL(e.SegundoNombre,'')) <> '' THEN ' '+TRIM(COALESCE(e.SegundoNombre,'')) ELSE '' END +' '+
				                        TRIM(COALESCE(e.Paterno,''))+' '+
				                        TRIM(CASE WHEN ISNULL(e.Materno,'') <> '' THEN ' '+COALESCE(e.Materno,'') ELSE '' END)
				                        )),'  ',' ') AS NombreCompleto
               ,CASE WHEN fe.IDEmpleado IS NOT NULL 
                     THEN cast(1 as bit) 
                     ELSE cast(0 as bit)
                END AS ExisteFotoColaborador 
               ,e.IDEmpleado AS ID
        FROM RH.tblEmpleados E            
            LEFT JOIN [RH].[tblFotosEmpleados] FE with (nolock) 
                ON FE.IDEmpleado = E.IDEmpleado  
        WHERE e.IDEmpleado=@IDEmpleado
        for json path, without_array_wrapper
    )        
    END
        
    RETURN @Result;
END;
GO
