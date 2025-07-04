USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [IMSS].[spIUCorreccionAccidente](
	@IDCorreccionAccidente	int
    ,@Descripcion	 varchar(255)
    ,@Origen		 varchar(50)
	,@IDUsuario int
) as
    select  @Descripcion	=upper(@Descripcion)	
		 ,@Origen		=upper(@Origen);		

		 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

    if ((@IDCorreccionAccidente = 0) or (@IDCorreccionAccidente is null))
    begin
	   insert into [Imss].[tblCatCorreccionesAccidentes](Descripcion,Origen)   
	   select @Descripcion, @Origen

	   select @IDCorreccionAccidente=@@identity

	    select @NewJSON = a.JSON from [IMSS].[tblCatCorreccionesAccidentes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCorreccionAccidente = @IDCorreccionAccidente

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatCorreccionesAccidentes]','[IMSS].[spIUCorreccionAccidente]','INSERT',@NewJSON,''
		

    end else
    begin

	   select @OldJSON = a.JSON from [IMSS].[tblCatCorreccionesAccidentes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCorreccionAccidente = @IDCorreccionAccidente

	   update [Imss].[tblCatCorreccionesAccidentes]
	   set Descripcion = @Descripcion
		  ,Origen = @Origen
	   where IDCorreccionAccidente=@IDCorreccionAccidente	
	   
	     select @NewJSON = a.JSON from [IMSS].[tblCatCorreccionesAccidentes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCorreccionAccidente = @IDCorreccionAccidente

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatCorreccionesAccidentes]','[IMSS].[spIUCorreccionAccidente]','INSERT',@NewJSON,@OldJSON
		
	      
    end;

    exec [Imss].[spBuscarCorreccionAccidente] @IDCorreccionAccidente=@IDCorreccionAccidente
GO
