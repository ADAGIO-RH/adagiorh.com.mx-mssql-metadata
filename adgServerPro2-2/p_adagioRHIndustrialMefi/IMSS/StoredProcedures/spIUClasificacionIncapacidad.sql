USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [IMSS].[spIUClasificacionIncapacidad](
	@IDClasificacionIncapacidad	int 
    ,@Codigo	varchar(10)
    ,@Nombre	varchar(100)
	,@IDUsuario int
) as
    select   @Codigo  = UPPER(@Codigo)
		  ,@Nombre  = UPPER(@Nombre)

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);


    if ((@IDClasificacionIncapacidad = 0) or (@IDClasificacionIncapacidad is null))
    begin
	   insert into [Imss].[tblCatClasificacionesIncapacidad](Codigo,Nombre)
	   select @Codigo,@Nombre

	   set @IDClasificacionIncapacidad = @@identity;

	     select @NewJSON = a.JSON from [IMSS].[tblCatClasificacionesIncapacidad] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClasificacionIncapacidad = @IDClasificacionIncapacidad

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatClasificacionesIncapacidad]','[IMSS].[spIUClasificacionIncapacidad]','INSERT',@NewJSON,''
		

    end else
    begin

	 select @OldJSON = a.JSON from [IMSS].[tblCatClasificacionesIncapacidad] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClasificacionIncapacidad = @IDClasificacionIncapacidad

	   update [Imss].[tblCatClasificacionesIncapacidad]
	   set 
	   Codigo = @Codigo
	   ,Nombre = @Nombre
	   where IDClasificacionIncapacidad = @IDClasificacionIncapacidad

	   
	     select @NewJSON = a.JSON from [IMSS].[tblCatClasificacionesIncapacidad] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClasificacionIncapacidad = @IDClasificacionIncapacidad

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatClasificacionesIncapacidad]','[IMSS].[spIUClasificacionIncapacidad]','UPDATE',@NewJSON,@OldJSON
		

    end;

    exec [Imss].[spBuscarClasificacionesIncapacidad] @IDClasificacionIncapacidad = @IDClasificacionIncapacidad
GO
