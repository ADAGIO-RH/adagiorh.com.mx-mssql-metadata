USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Compensaciones].[spIUMatrizIncremento](  
	 @IDMatrizIncremento int = 0
	,@Fecha Date 
	,@Descripcion Varchar(500)
	,@IDEvaluacion			int = 0
	,@ValorInicial			decimal(18,4) null
	,@QtyNivelesAmplitud		int null
	,@ValorNivelesAmplitud	decimal(18,4) null
	,@ValorCentralAmplitud	decimal(18,4) null
	,@QtyNivelesProgresion	int null
	,@ValorNivelesProgresion decimal(18,4) null
	,@Progresiva			 bit =  null
	,@IDUsuario int  
)  
AS  
BEGIN  
  	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	select 
		@Descripcion = UPPER(@Descripcion )  
	;
  
	if (@Descripcion is null or isnull(@Descripcion,'') = '')   
	begin  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302004'  
		RETURN 0;  
	end;  
	
  
	IF (@IDMatrizIncremento = 0 or @IDMatrizIncremento is null)  
	BEGIN  
		IF EXISTS(Select Top 1 1 from [Compensaciones].[tblMatrizIncremento] where Fecha = @Fecha)  
		BEGIN  
			EXEC [App].[spObtenerError] @IDUsuario = 1, @CodigoError = '0302003'  
			RETURN 0;  
		END  
  
		INSERT INTO [Compensaciones].[tblMatrizIncremento](  
			Fecha
			,Descripcion
			,IDEvaluacion
			,ValorInicial
			,QtyNivelesAmplitud
			,ValorNivelesAmplitud
			,ValorCentralAmplitud
			,QtyNivelesProgresion
			,ValorNivelesProgresion
			,Progresiva
       )  
		VALUES (  
			@Fecha
			,@Descripcion
			,@IDEvaluacion
			,@ValorInicial
			,@QtyNivelesAmplitud
			,@ValorNivelesAmplitud
			,@ValorCentralAmplitud
			,@QtyNivelesProgresion
			,@ValorNivelesProgresion
			,isnull(@Progresiva,0)
       )  
    
		set @IDMatrizIncremento = @@identity  

		select @NewJSON = a.JSON from [Compensaciones].[tblMatrizIncremento] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMatrizIncremento = @IDMatrizIncremento

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Compensaciones].[tblMatrizIncremento]','[Compensaciones].[spIUMatrizIncremento]','INSERT',@NewJSON,''
	END  
	ELSE  
	BEGIN  

		select @OldJSON = a.JSON 
		from [Compensaciones].[tblMatrizIncremento] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMatrizIncremento = @IDMatrizIncremento

		UPDATE [Compensaciones].[tblMatrizIncremento]
		SET  
				
			Fecha				= @Fecha			
			,Descripcion		= @Descripcion	
			,IDEvaluacion			= @IDEvaluacion			
			,ValorInicial			= @ValorInicial			
			,QtyNivelesAmplitud		= @QtyNivelesAmplitud		
			,ValorNivelesAmplitud	= @ValorNivelesAmplitud	
			,ValorCentralAmplitud	= @ValorCentralAmplitud	
			,QtyNivelesProgresion	= @QtyNivelesProgresion	
			,ValorNivelesProgresion	= @ValorNivelesProgresion
			,Progresiva				= @Progresiva
		WHERE IDMatrizIncremento = @IDMatrizIncremento  
  	
		select @NewJSON = a.JSON from [Compensaciones].[tblMatrizIncremento] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMatrizIncremento = @IDMatrizIncremento

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Compensaciones].[tblMatrizIncremento]','[Compensaciones].[spIUMatrizIncremento]','UPDATE',@NewJSON,@OldJSON
	END  
 	
END
GO
