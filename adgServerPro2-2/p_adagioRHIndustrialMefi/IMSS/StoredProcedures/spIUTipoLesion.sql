USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [IMSS].[spIUTipoLesion](  
 @IDTipoLesion int  
    ,@Codigo varchar(20)  
    ,@Descripcion  varchar(255)  
    ,@IDUsuario int  
) as  
    select  @Descripcion =upper(@Descripcion)  
    ,@Codigo = upper(@Codigo)  
    ;  
  
  	 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);
  
    if ((@IDTipoLesion = 0) or (@IDTipoLesion is null))  
    begin  
		if EXISTS(select top 1 1  
		  from [Imss].[tblCatTiposLesiones]  
		  where Codigo = @Codigo)  
		BEGIN  
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
			RETURN 0;  
		END  
  
		insert into [Imss].[tblCatTiposLesiones](Codigo,Descripcion)     
		select @Codigo,@Descripcion  
  
		select @IDTipoLesion=@@identity  

		
	    select @NewJSON = a.JSON from [IMSS].[tblCatTiposLesiones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoLesion = @IDTipoLesion

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatTiposLesiones]','[IMSS].[spIUTipoLesion]','INSERT',@NewJSON,''
		


    end else  
    begin  
		if EXISTS(select top 1 1  
		  from [Imss].[tblCatTiposLesiones]  
		  where (Codigo = @Codigo) and ( IDTipoLesion <> @IDTipoLesion))  
		BEGIN  
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
			RETURN 0;  
		END  
  
		select @OldJSON = a.JSON from [IMSS].[tblCatTiposLesiones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoLesion = @IDTipoLesion

	
		update [Imss].[tblCatTiposLesiones]  
		set Descripcion = @Descripcion  
		, Codigo = @Codigo
		where IDTipoLesion=@IDTipoLesion 
		
		 select @NewJSON = a.JSON from [IMSS].[tblCatTiposLesiones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoLesion = @IDTipoLesion

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatTiposLesiones]','[IMSS].[spIUTipoLesion]','UPDATE',@NewJSON,@OldJSON
		
     
    end;  
  
    exec [Imss].[spBuscarTiposLesiones] @IDTipoLesion=@IDTipoLesion
GO
