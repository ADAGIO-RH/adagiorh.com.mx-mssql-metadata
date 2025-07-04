USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarEmpleadoMasterByID]              
(  
    @IDEmpleado int ,
    @IDUsuario int
)              
AS              
BEGIN              
SET QUERY_GOVERNOR_COST_LIMIT 0;        
SET FMTONLY OFF;   



    SELECT 
    IDEmpleado,
    ClaveEmpleado,
    NOMBRECOMPLETO [NombreCompleto],
    Departamento,
    Sucursal,
    Puesto,
    Materno,
    Nombre,
    Paterno,
    SegundoNombre,
    Vigente,
    Utilerias.fnGetUrlFotoUsuario(ClaveEmpleado) as UrlFoto ,
    SUBSTRING(coalesce(e.Nombre, ''), 1, 1)+SUBSTRING(coalesce(e.Paterno, coalesce(e.Materno, '')), 1, 1) as Iniciales
    fROM RH.tblEmpleadosMaster  e
    WHERE IDEmpleado =@IDEmpleado
END
GO
