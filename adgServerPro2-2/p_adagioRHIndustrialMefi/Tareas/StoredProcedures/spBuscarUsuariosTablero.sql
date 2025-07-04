USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx
** FechaCreacion : 2022-07-04
** Paremetros  :
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor   Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROCEDURE [Tareas].[spBuscarUsuariosTablero]
(	
    @IDUsuario int ,
    @IDTablero int,
    @IDTipoTablero int 
)
AS
BEGIN	 
    select 
    isnull(u.IDEmpleado,0) as IDEmpleado,
        u.IDUsuario,COALESCE(ClaveEmpleado,'N/A') As ClaveEmpleado, 
        COALESCE(e.Nombre,u.Nombre) as Nombre , 
        COALESCE(e.NombreCompleto,(concat(isnull(u.Nombre,''),' ',isnull(u.Apellido,'') ) ))  AS NombreCompleto,
        e.Puesto,
        e.Departamento,
        e.Sucursal 
    FROM tareas.tblTableroUsuarios tu
    inner JOIN Seguridad.tblUsuarios u on u.IDUsuario=tu.IDUsuario
    LEFT JOIN RH.tblEmpleadosMaster e on e.IDEmpleado=u.IDEmpleado
    where IDTipoTablero=@IDTipoTablero and IDReferencia=@IDTablero
END
GO
