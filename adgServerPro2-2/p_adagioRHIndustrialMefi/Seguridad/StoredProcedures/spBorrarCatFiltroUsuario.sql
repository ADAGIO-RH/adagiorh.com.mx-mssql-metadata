USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBorrarCatFiltroUsuario](    
 @IDCatFiltroUsuario int    
 ,@IDUsuarioCreo int    
)    
as    
 declare @IDUsuario int = 0,
 @OldJSON Varchar(Max);
    
 select @IDUsuario = IDUsuario    
 from [Seguridad].[tblCatFiltrosUsuarios]    
 where IDCatFiltroUsuario= @IDCatFiltroUsuario

SELECT @OldJSON = (SELECT FU.*,U.IDEmpleado,U.Nombre as [Nombre Usuario], u.Apellido FROM Seguridad.tblCatFiltrosUsuarios FU     
                inner join Seguridad.TblUsuarios U on U.IDUsuario =FU.IDUsuario   
                WHERE FU.IDUsuario = @IDUsuario AND IDCatFiltroUsuario = @IDCatFiltroUsuario FOR JSON PATH,WITHOUT_ARRAY_WRAPPER);

  Delete [Seguridad].[tblCatFiltrosUsuarios]
 where IDCatFiltroUsuario = @IDCatFiltroUsuario 

 --Delete [Seguridad].[tblFiltrosUsuarios]
 --where IDCatFiltroUsuario = @IDCatFiltroUsuario  

 exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuarioCreo

      EXEC [Auditoria].[spIAuditoria] @IDUsuarioCreo,'[Seguridad].[tblCatFiltrosUsuarios]','[Seguridad].[spBorrarCatFiltroUsuario]','DELETE','',@OldJSON
GO
