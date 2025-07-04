USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Asistencia].[spIUCatGruposHorarios]
(
  @IDGrupoHorario int  = 0
 ,@Descripcion varchar(255)
 ,@IDUsuario int
) as
BEGIN


 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	SET @Descripcion = UPPER(@Descripcion)

    if (@IDGrupoHorario  <> 0)
    begin

	select @OldJSON = a.JSON from [Asistencia].[tblCatGruposHorarios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDGrupoHorario = @IDGrupoHorario

	   update [Asistencia].[tblCatGruposHorarios]
		  set Descripcion = @Descripcion
	   where IDGrupoHorario = @IDGrupoHorario

	   select @NewJSON = a.JSON from [Asistencia].[tblCatGruposHorarios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDGrupoHorario = @IDGrupoHorario
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatGruposHorarios]','[Asistencia].[spIUCatGruposHorarios]','UPDATE',@NewJSON,@OldJSON
		

    end else
    begin
	   insert into [Asistencia].[tblCatGruposHorarios](Descripcion)
	   select @Descripcion  
	   
	   set @IDGrupoHorario=@@IDENTITY 

	      select @NewJSON = a.JSON from [Asistencia].[tblCatGruposHorarios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDGrupoHorario = @IDGrupoHorario
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatGruposHorarios]','[Asistencia].[spIUCatGruposHorarios]','INSERT',@NewJSON,''
		
    end;

    exec [Asistencia].[spBuscarCatGruposHorarios] @IDGrupoHorario=@IDGrupoHorario,@IDUsuario = @IDUsuario
END;
GO
