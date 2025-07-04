USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reclutamiento].[spIUEstatusProceso](
	@IDEstatusProceso int = 0
	,@Traduccion varchar(max)
	,@MostrarEnProcesoSeleccion bit
	,@Orden int
	,@Color varchar(10)
	,@ProcesoFinal bit = 0
	,@IDPlantilla int = 0
	,@Activa bit = 1
	,@IDUsuario int = 0 
)
AS  
BEGIN  

	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@Accion varchar(20),
		@TraduccionActual varchar(max),
		
		@RecalcularOrden int = 0
	;

	if ((@Orden is null) or (@Orden = 0))
    begin
	   select @Orden=isnull(Max(isnull(Orden,0))+1,1) from Reclutamiento.tblCatEstatusProceso
    end else
	  set @RecalcularOrden = 1;

	IF(isnull(@IDEstatusProceso,0) = 0)  
	BEGIN  
		INSERT INTO [Reclutamiento].[tblCatEstatusProceso]( 
			[MostrarEnProcesoSeleccion]
			,[Orden]
			,[Color]
			,ProcesoFinal
			,IDPlantilla
			,Traduccion
			,Activa
		)
		VALUES( 
           @MostrarEnProcesoSeleccion
           ,@Orden
		   ,@Color
		   ,@ProcesoFinal
		   ,@IDPlantilla
		   ,@Traduccion
		   ,@Activa
		)

		SET @IDEstatusProceso = @@IDENTITY  

		select @NewJSON = a.JSON 
			,@Accion = 'INSERT'
		from [Reclutamiento].[tblCatEstatusProceso] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEstatusProceso = @IDEstatusProceso
	END  
	ELSE  
	BEGIN  
		/*
			No se permite modificar el nombre y la descripción de un estatus predeterminado, 
			Aquí actualizamos la variable con la traducción de la base de datos en caso de que 
			se trate de un estatus predeterminado, en caso contrario, mantemos el valor de la
			variable.
		*/

		select 
			@Traduccion = case 
							when UUIDDefault is null then @Traduccion else Traduccion end
		from [Reclutamiento].[tblCatEstatusProceso]
		WHERE IDEstatusProceso = @IDEstatusProceso

		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Reclutamiento].[tblCatEstatusProceso] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE  b.IDEstatusProceso = @IDEstatusProceso

		UPDATE [Reclutamiento].[tblCatEstatusProceso]
		   SET 
				[MostrarEnProcesoSeleccion] = @MostrarEnProcesoSeleccion
				,[Orden]		= @Orden
				,[Color]		= @Color
				,[ProcesoFinal] = @ProcesoFinal
				,[IDPlantilla]	= @IDPlantilla
				,Traduccion		= @Traduccion
				,Activa			= @Activa
		WHERE IDEstatusProceso = @IDEstatusProceso

	END  

	if (@RecalcularOrden = 1)
	begin
		exec [Reclutamiento].[spActualizarOrdenEstatusProceso] 
			@IDEstatusProceso = @IDEstatusProceso 
			,@OldIndex = 0  
			,@NewIndex = @Orden
			,@IDUsuario = @IDUsuario
	end;

	--select @NewJSON = a.JSON from [Reclutamiento].[tblCatEstatusProceso] b
	--Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	--WHERE  b.IDEstatusProceso = @IDEstatusProceso
			   
	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCatEstatusProceso]','[Reclutamiento].[spIUEstatusProceso]',@Accion,@NewJSON,@OldJSON
END
GO
