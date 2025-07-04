USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spIUCatTurno](  
 @IDTurno int    
    ,@IDTipoJornadaSAT int   
    ,@Descripcion varchar(255) 
	,@IDUsuario int 
) as  
begin  
    DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);
 SET @Descripcion = UPPER(@Descripcion)  
  
    if (@IDTurno <> 0)  
    begin  
		select @OldJSON = a.JSON from [Asistencia].[tblCatTurnos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTurno = @IDTurno     

			update [Asistencia].[tblCatTurnos]  
			set IDTipoJornadaSAT = @IDTipoJornadaSAT  
		   ,Descripcion = @Descripcion  
		  where IDTurno = @IDTurno    
		 
		  select @NewJSON = a.JSON from [Asistencia].[tblCatTurnos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTurno = @IDTurno     

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatTurnos]','[Asistencia].[spIUCatTurno]','UPDATE',@NewJSON,@OldJSON
		
		   
    end else  
    begin  
		insert into [Asistencia].[tblCatTurnos](IDTipoJornadaSAT, Descripcion)  
		select @IDTipoJornadaSAT, @Descripcion  
  
		set @IDTurno = @@IDENTITY;  

		 
		  select @NewJSON = a.JSON from [Asistencia].[tblCatTurnos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTurno = @IDTurno     

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatTurnos]','[Asistencia].[spIUCatTurno]','INSERT',@NewJSON,''
		
    end;  
  
    exec [Asistencia].[spBuscarTurno] @IDTurno=@IDTurno;  
end;
GO
