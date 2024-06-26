USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Buscar los usuarios registrados en la base de datos filtrados por el parámetro @filter  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2020-05-05  
** Paremetros  :                
  
** DataTypes Relacionados:   
 [Seguridad].[dtUsuarios]  
  
 Si se modifica el result set de este sp será necesario modificar los siguientes sp:  
  [App].[INotificacionActivarCuenta]  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROCEDURE [Seguridad].[spFilterUsuarios]  
(  
 @IDUsuario int = 0,  
 @filter varchar(255)  
)  
AS  
BEGIN  
 Select   
  u.IDUsuario  
  ,isnull(u.IDEmpleado,0) as IDEmpleado  
  ,coalesce(e.ClaveEmpleado,'') as ClaveEmpleado  
  ,u.Cuenta  
  ,null as [Password]  
  ,isnull(u.IDPreferencia,0) as IDPreferencia  
  ,coalesce(u.Nombre,'') as Nombre  
  ,coalesce(u.Apellido,'') as Apellido  
  ,coalesce(u.Sexo,'') as Sexo  
  --,Nombre = case when e.IDEmpleado is not null then e.Nombre  
  --      else u.Nombre end  
  --,Apellido = case when e.IDEmpleado is not null then coalesce(e.Paterno,'')+' '+coalesce(e.Materno,'')  
  --      else u.Apellido end  
  --,Sexo = case when e.IDEmpleado is not null then e.Sexo else '' end  
  ,u.Email  
  ,isnull(u.Activo,0) as Activo   
  ,ISNULL(U.IDPerfil,0) as IDPerfil  
  ,P.Descripcion as Perfil  
  ,isnull(u.Supervisor,0) as Supervisor
  ,'' as [URL]  
  ,ROW_NUMBER()over(ORDER BY IDUsuario) as ROWNUMBER  
 from Seguridad.tblUsuarios u with (nolock)   
  left join [RH].[tblEmpleados] e with (nolock) on u.IDEmpleado = e.IDEmpleado  
  inner join Seguridad.tblCatPerfiles P with (nolock)  
   on U.IDPerfil = P.IDPerfil  
 Where (u.Cuenta+' '+coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'')) like '%'+@filter+'%'     
END
GO
