USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [IMSS].[spIUCausaAccidente](
	@IDCausaAccidente	int
    ,@Descripcion	 varchar(255)
    ,@Origen		 varchar(50)
	,@IDUsuario int
) as
    select  @Descripcion	=upper(@Descripcion)	
		 ,@Origen		=upper(@Origen);		

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

    if ((@IDCausaAccidente = 0) or (@IDCausaAccidente is null))
    begin
	   insert into [Imss].[tblCatCausasAccidentes](Descripcion,Origen)   
	   select @Descripcion, @Origen

	   select @IDCausaAccidente=@@identity

	   select @NewJSON = a.JSON from [IMSS].[tblCatCausasAccidentes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCausaAccidente = @IDCausaAccidente

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatCausasAccidentes]','[IMSS].[spIUCausaAccidente]','INSERT',@NewJSON,''
		
		

    end else
    begin

		  select @OldJSON = a.JSON from [IMSS].[tblCatCausasAccidentes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCausaAccidente = @IDCausaAccidente

	   update [Imss].[tblCatCausasAccidentes]
	   set Descripcion = @Descripcion
		  ,Origen = @Origen
	   where IDCausaAccidente=@IDCausaAccidente	   

	      select @NewJSON = a.JSON from [IMSS].[tblCatCausasAccidentes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCausaAccidente = @IDCausaAccidente

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatCausasAccidentes]','[IMSS].[spIUCausaAccidente]','UPDATE',@NewJSON,@OldJSON
		
		

    end;

    exec [Imss].[spBuscarCausaAccidente] @IDCausaAccidente=@IDCausaAccidente
GO
