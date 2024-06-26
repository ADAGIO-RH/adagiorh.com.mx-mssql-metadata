USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reclutamiento].[spIUEstatusProceso](
								@IDEstatusProceso int = 0
							   ,@Descripcion varchar(50)
							   ,@MostrarEnProcesoSeleccion int
							   ,@Orden int
							   ,@Color varchar(10)
							   ,@IDUsuario int = 0 
						    )
AS  
BEGIN  

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

 IF(@IDEstatusProceso = 0)  
 BEGIN  


	INSERT INTO [Reclutamiento].[tblCatEstatusProceso]
           ([IDEstatusProceso]
           ,[Descripcion]
           ,[MostrarEnProcesoSeleccion]
           ,[Orden]
		   ,[Color])
     VALUES
           (@IDEstatusProceso
           ,@Descripcion
           ,@MostrarEnProcesoSeleccion
           ,@Orden
		   ,@Color)


		SET @IDEstatusProceso = @@IDENTITY  


			select @NewJSON = a.JSON from [Reclutamiento].[tblCatEstatusProceso] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDEstatusProceso = @IDEstatusProceso

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCatEstatusProceso]','[Reclutamiento].[spIUEstatusProceso]','INSERT',@NewJSON,''
		

 END  
 ELSE  
 BEGIN  
	  	select @OldJSON = a.JSON from [Reclutamiento].[tblCatEstatusProceso] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE  b.IDEstatusProceso = @IDEstatusProceso



		UPDATE [Reclutamiento].[tblCatEstatusProceso]
		   SET [IDEstatusProceso] = @IDEstatusProceso
			  ,[Descripcion] = @Descripcion
			  ,[MostrarEnProcesoSeleccion] = @MostrarEnProcesoSeleccion
			  ,[Orden] = @Orden
			  ,[Color] = @Color
		 WHERE IDEstatusProceso = @IDEstatusProceso

		select @NewJSON = a.JSON from [Reclutamiento].[tblCatEstatusProceso] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE  b.IDEstatusProceso = @IDEstatusProceso
			   
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCatEstatusProceso]','[Reclutamiento].[spIUEstatusProceso]','UPDATE',@NewJSON,@OldJSON

 END  

	EXEC [Reclutamiento].[spBuscarEstatusProceso] @IDEstatusProceso = @IDEstatusProceso

END
GO
