USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Buscar los usuarios registrados en la base de datos filtrados por los adgfiltros  
** Autor   : Jose Vargas
** Email   : jvargas.abreu@adagio.com.mx  
** FechaCreacion : 2022-02-02  
** Paremetros  :                
  @dtFiltros -> IDEMPLEADO  
      null = trae todos los usuarios sean o no empleados
      0 = trae los usuarios que no sean empleados
      1 = trae los usuarios que son empleados      
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROCEDURE [Seguridad].[spFilterUsuariosWithAdgFiltros]  
(  
 @IDUsuario int = 0,  
 @dtFiltros [Nomina].[dtFiltrosRH] READONLY              
)  
AS  
BEGIN  

    declare  @vigente int ,
            @search varchar(max),
            @IDEmpleado int
        
        Select  @search=isnull(Value,'') from @dtFiltros where Catalogo = 'Search'
        Select  @vigente=Value from @dtFiltros where Catalogo = 'Vigente'
        Select  @IDEmpleado=Value from @dtFiltros where Catalogo = 'IDEmpleado'
        set @search=isnull(@search,'')

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
        Where (u.Cuenta+' '+coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'')) like '%'+@search+'%'   
                and (u.Activo = case when @vigente is not null then @vigente else u.Activo end) 
                and ((e.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))               
                or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))              
                and ( @IDEmpleado is null or (@IDEmpleado=0  and ( isnull(u.IDEmpleado,0)=0 or u.IDEmpleado=0)) or (@IDEmpleado =1 and  u.IDEmpleado <> 0 and u.IDEmpleado is not null) )
END
GO
