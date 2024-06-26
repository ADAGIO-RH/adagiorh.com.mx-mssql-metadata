USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[Reclutamiento].[spIUEstatusProceso]@IDEstatusProceso=1,
--										@Descripcion='NUEVO',
--										@MostrarEnProcesoSeleccion=1,
--										@Orden=1,
--										@Color='#548dd4',
--										@ProcesoFinal=0,
--										@IDPlantilla=1,
--										@IDUsuario=1
CREATE proc [Reclutamiento].[spIUEstatusProceso](
								@IDEstatusProceso int = 0
							   ,@Descripcion varchar(50)
							   ,@MostrarEnProcesoSeleccion bit
							   ,@Orden int
							   ,@Color varchar(10)
							   ,@ProcesoFinal bit = 0
							   ,@IDPlantilla int = 0
							   ,@IDUsuario int = 0 
						    )
AS  
BEGIN  

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	set @Descripcion = UPPER(@Descripcion)

	 IF(isnull(@IDEstatusProceso,0) = 0)  
	 BEGIN  
		INSERT INTO [Reclutamiento].[tblCatEstatusProceso]
           ( [Descripcion]
           ,[MostrarEnProcesoSeleccion]
           ,[Orden]
		   ,[Color]
		   ,ProcesoFinal,
		   IDPlantilla)
		VALUES
           ( @Descripcion
           ,@MostrarEnProcesoSeleccion
           ,@Orden
		   ,@Color
		   ,@ProcesoFinal
		   ,@IDPlantilla)

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
		   SET [Descripcion] = @Descripcion
			  ,[MostrarEnProcesoSeleccion] = @MostrarEnProcesoSeleccion
			  ,[Orden] = @Orden
			  ,[Color] = @Color
			  ,[ProcesoFinal] = @ProcesoFinal
			  ,[IDPlantilla] = @IDPlantilla
		 WHERE IDEstatusProceso = @IDEstatusProceso

		select @NewJSON = a.JSON from [Reclutamiento].[tblCatEstatusProceso] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE  b.IDEstatusProceso = @IDEstatusProceso
			   
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCatEstatusProceso]','[Reclutamiento].[spIUEstatusProceso]','UPDATE',@NewJSON,@OldJSON

 END  
END
GO
