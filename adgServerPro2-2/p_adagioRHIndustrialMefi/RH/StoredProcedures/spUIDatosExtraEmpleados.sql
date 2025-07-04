USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUIDatosExtraEmpleados](  
	@IDDatoExtra int,  
	@IDDatoExtraEmpleado int = 0,  
	@Valor varchar(255),
	@IDEmpleado int,  
	@IDUsuario int  
)  
AS  
BEGIN  
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	set @Valor = REPLACE(@Valor,CHAR(10),'')
	set @Valor = REPLACE(@Valor,CHAR(13),'')

	IF(@IDDatoExtraEmpleado = 0)  
	BEGIN  
		INSERT INTO RH.tblDatosExtraEmpleados(IDDatoExtra,Valor,IDEmpleado)  
		VALUES(@IDDatoExtra,upper(@Valor),@IDEmpleado)  
		
		SET @IDDatoExtraEmpleado = @@IDENTITY  

		select @NewJSON = a.JSON from [RH].[tblDatosExtraEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDatoExtraEmpleado = @IDDatoExtraEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblDatosExtraEmpleados]','[RH].[spUIDatosExtraEmpleados]','INSERT',@NewJSON,''
	END  
	ELSE  
	BEGIN  
	  	select @OldJSON = a.JSON from [RH].[tblDatosExtraEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDatoExtraEmpleado = @IDDatoExtraEmpleado
			and IDDatoExtra = @IDDatoExtra 
			AND IDEmpleado = @IDEmpleado 

		UPDATE RH.tblDatosExtraEmpleados  
			set 
				Valor = upper(@Valor)  
		WHERE IDDatoExtraEmpleado = @IDDatoExtraEmpleado  
			and IDDatoExtra = @IDDatoExtra 
			AND IDEmpleado = @IDEmpleado 

		select @NewJSON = a.JSON from [RH].[tblDatosExtraEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDatoExtraEmpleado = @IDDatoExtraEmpleado
				and b.IDDatoExtra = @IDDatoExtra 
				AND b.IDEmpleado = @IDEmpleado 

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblDatosExtraEmpleados]','[RH].[spUIDatosExtraEmpleados]','UPDATE',@NewJSON,@OldJSON
	END  
END
GO
