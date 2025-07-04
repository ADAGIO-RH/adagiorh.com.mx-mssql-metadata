USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [FirmaDigital].[spUIDocumentosFirmantes](
	 @IDFirmante Varchar(255) 
	,@ID Varchar(255)
	,@Email Varchar(255)
	,@Name Varchar(255)
	,@TaxId Varchar(255) = null
	,@Signed bit = null
	,@WidgetID Varchar(255) = null
	,@Current bit = null
    ,@AllowedSignatureMethods Varchar(255) = null
)
AS
BEGIN

	IF(isnull(@Email,'') = '' )
	BEGIN
		 RAISERROR('El Email del Firmante del Documento es requerido', 16, 1) --change to > 10
		 return
	END
	IF(isnull(@Name,'') = '' )
	BEGIN
		 RAISERROR('El Nombre del Firmante del Documento es requerido', 16, 1) --change to > 10
		 return
	END
	SET @Name = UPPER(@Name)

	IF NOT EXISTS (Select top 1 1 from [FirmaDigital].[tblDocumentosFirmantes] where  (ID = @ID and IDFirmante = @IDFirmante))
	BEGIN
		INSERT INTO [FirmaDigital].[tblDocumentosFirmantes](
			 ID
			,IDFirmante
			,Email
			,[Name]
			,TaxId
			,Signed
			,WidgetID
			,[Current]
            ,AllowedSignatureMethods
		)
		VALUES (
			 @ID
			,@IDFirmante
			,@Email
			,@Name
			,@TaxId
			,@Signed
			,@WidgetID
			,@Current
            ,@AllowedSignatureMethods
		
		)
	END
	ELSE
	BEGIN
		UPDATE [FirmaDigital].[tblDocumentosFirmantes]
			set  Signed	   = @Signed	   
				,WidgetID  = @WidgetID  
				,[Current] = @Current
				,[Name]    = @Name
 		WHERE (ID = @ID and IDFirmante = @IDFirmante)

	END
END
GO
