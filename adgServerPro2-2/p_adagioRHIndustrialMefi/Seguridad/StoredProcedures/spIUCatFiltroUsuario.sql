USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spIUCatFiltroUsuario](
	 @IDCatFiltroUsuario int = 0	
	,@IDUsuario int			
	,@Nombre varchar(255)	
	,@IDUsuarioCreo int		
) as


    DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);




	if (ISNULL(@IDCatFiltroUsuario,0) = 0)
	begin
		insert Seguridad.tblCatFiltrosUsuarios(IDUsuario,Nombre,IDUsuarioCreo)
		values (@IDUsuario,@Nombre,@IDUsuarioCreo)

		set @IDCatFiltroUsuario = @@IDENTITY

    Select @NewJSON =  (SELECT FU.*,U.IDEmpleado,U.Nombre as [Nombre Usuario], u.Apellido FROM Seguridad.tblCatFiltrosUsuarios FU     
                inner join Seguridad.TblUsuarios U on U.IDUsuario =FU.IDUsuario   
                WHERE FU.IDUsuario = @IDUsuario AND IDCatFiltroUsuario = @IDCatFiltroUsuario FOR JSON PATH,WITHOUT_ARRAY_WRAPPER);

        	EXEC [Auditoria].[spIAuditoria] @IDUsuarioCreo,'[Seguridad].[tblCatFiltrosUsuarios]','[Seguridad].[spIUCatFiltroUsuario]','INSERT',@NewJSON,''
	end else
	begin
     Select @OldJSON =  (SELECT FU.*,U.IDEmpleado,U.Nombre as [Nombre Usuario], u.Apellido FROM Seguridad.tblCatFiltrosUsuarios FU     
                inner join Seguridad.TblUsuarios U on U.IDUsuario =FU.IDUsuario   
                WHERE FU.IDUsuario = @IDUsuario AND IDCatFiltroUsuario = @IDCatFiltroUsuario FOR JSON PATH,WITHOUT_ARRAY_WRAPPER);

		update Seguridad.tblCatFiltrosUsuarios
			set Nombre = @Nombre
		where IDCatFiltroUsuario = @IDCatFiltroUsuario

         Select @NewJSON =  (SELECT FU.*,U.IDEmpleado,U.Nombre as [Nombre Usuario], u.Apellido FROM Seguridad.tblCatFiltrosUsuarios FU     
                inner join Seguridad.TblUsuarios U on U.IDUsuario =FU.IDUsuario   
                WHERE FU.IDUsuario = @IDUsuario AND IDCatFiltroUsuario = @IDCatFiltroUsuario FOR JSON PATH,WITHOUT_ARRAY_WRAPPER);
         
         EXEC [Auditoria].[spIAuditoria] @IDUsuarioCreo,'[Seguridad].[tblCatFiltrosUsuarios]','[Seguridad].[spIUCatFiltroUsuario]','UPDATE',@NewJSON,@OldJSON
	end;
	
	exec Seguridad.spBuscarCatFiltrosUsuario @IDCatFiltroUsuario = @IDCatFiltroUsuario, @IDUsuario = @IDUsuario
GO
