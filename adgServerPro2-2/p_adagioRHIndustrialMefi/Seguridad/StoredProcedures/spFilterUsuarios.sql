USE [p_adagioRHIndustrialMefi]
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
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROCEDURE [Seguridad].[spFilterUsuarios](  
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
		,u.Nombre
		,u.Apellido
        ,e.RFC
		,NombreCompleto = coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'')
		,coalesce(u.Sexo,'') as Sexo
		,u.Email
		,isnull(u.Activo,0) as Activo 
		,EsColaborador = case when isnull(u.IDEmpleado,0) <> 0 then cast(1 as bit) else cast(0 as bit) end
		,isnull(e.Vigente,cast(0 as bit)) as Vigente 
		,ISNULL(U.IDPerfil,0) as IDPerfil
		,P.Descripcion as Perfil
		,'' as [URL]
		,isnull(u.Supervisor,0) as Supervisor 
		,isnull(candidato.IDCandidato,0) as IDCandidato 
        , case when fe.IDEmpleado is not null 
                then CONCAT('/Empleados/',e.ClaveEmpleado,'.jpg') 
                when fu.IDUsuario is not null 
                then CONCAT('/Usuarios/',fu.IDUsuario,'.jpg') 
                else
                    'Fotos/nofoto.jpg'
                end 
        as UrlFoto
		,1 as TotalPaginas
        ,isnull(u.ResetPassword,0) as ResetPassword
	from Seguridad.tblUsuarios u with (nolock)   
		left join [RH].[tblEmpleadosMaster] e with (nolock) on u.IDEmpleado = e.IDEmpleado  
		inner join Seguridad.tblCatPerfiles P with (nolock) on U.IDPerfil = P.IDPerfil  
		left join Reclutamiento.tblCandidatos candidato on Candidato.IDEmpleado = e.IDEmpleado
        left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado=u.IDEmpleado
        left join [Seguridad].[tblFotoUsuarios] fu with (nolock) on fu.IDUsuario=u.IDUsuario
	Where (u.Cuenta+' '+coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'')) like '%'+@filter+'%'     
END
GO
