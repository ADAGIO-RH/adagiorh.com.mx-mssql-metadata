USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [IMSS].[spIUTipoRiesgoIncapacidad](
	@IDTipoRiesgoIncapacidad int
    ,@Codigo  varchar(10)
    ,@Nombre  varchar(100)
	,@IDUsuario int
) as
    select  @Codigo = UPPER(@Codigo)
		 ,@Nombre = UPPER(@Nombre)

    
	 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);


    if ((@IDTipoRiesgoIncapacidad = 0) or (@IDTipoRiesgoIncapacidad is null))
    begin
	   insert into [Imss].[tblCatTipoRiesgoIncapacidad](Codigo,Nombre)
	   select @Codigo,@Nombre

	   set @IDTipoRiesgoIncapacidad = @@identity;

	      select @NewJSON = a.JSON from [IMSS].[tblCatTipoRiesgoIncapacidad] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoRiesgoIncapacidad = @IDTipoRiesgoIncapacidad

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatTipoRiesgoIncapacidad]','[IMSS].[spIUTipoRiesgoIncapacidad]','INSERT',@NewJSON,''
		


    end else
    begin 

		 select @OldJSON = a.JSON from [IMSS].[tblCatTipoRiesgoIncapacidad] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoRiesgoIncapacidad = @IDTipoRiesgoIncapacidad


	   update [Imss].[tblCatTipoRiesgoIncapacidad]
	   set Codigo = @Codigo
		  ,Nombre = @Nombre
	   where IDTipoRiesgoIncapacidad = @IDTipoRiesgoIncapacidad

	     select @NewJSON = a.JSON from [IMSS].[tblCatTipoRiesgoIncapacidad] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoRiesgoIncapacidad = @IDTipoRiesgoIncapacidad

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatTipoRiesgoIncapacidad]','[IMSS].[spIUTipoRiesgoIncapacidad]','UPDATE',@NewJSON,@OldJSON
		

    end;

    exec [Imss].[spBuscarTipoRiesgoIncapacidad] @IDTipoRiesgoIncapacidad = @IDTipoRiesgoIncapacidad
GO
