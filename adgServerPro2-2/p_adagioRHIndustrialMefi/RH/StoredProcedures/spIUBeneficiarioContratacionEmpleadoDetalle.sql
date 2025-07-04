USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [RH].[spIUBeneficiarioContratacionEmpleadoDetalle]  
(  
  @IDBeneficiarioContratacionEmpleadoDetalle int = 0
 ,@IDBeneficiarioContratacionEmpleado int 
 ,@IDCatBeneficiarioContratacion int
 ,@Porcentaje decimal(18,2)
 ,@IDUsuario int  
)  
AS  
BEGIN  
    Declare @msj nvarchar(max) ;  
  
	  DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	SET @Porcentaje = ISNULL(@Porcentaje,0)

	IF(ISNULL(@Porcentaje,0) <= 0)
	BEGIN
		set @msj= cast('El procentaje de tiempo para el beneficiario de contratación debe ser mayor que Cero.' as varchar(255));  
			raiserror(@msj,16,0);  
			RETURN;
	END
  
    IF(@IDBeneficiarioContratacionEmpleadoDetalle = 0 or @IDBeneficiarioContratacionEmpleadoDetalle is null)  
    BEGIN  
		if exists(select 1 from RH.tblBeneficiarioContratacionEmpleadoDetalle  
		where IDBeneficiarioContratacionEmpleado = @IDBeneficiarioContratacionEmpleado and IDCatBeneficiarioContratacion=@IDCatBeneficiarioContratacion)  
		begin  
			set @msj= cast('Ya existe un registro con este beneficiario de contratación en este historial.' as varchar(255));  
			raiserror(@msj,16,0);  
			RETURN;
		end;  
  
		INSERT INTO RH.tblBeneficiarioContratacionEmpleadoDetalle(IDBeneficiarioContratacionEmpleado,IDCatBeneficiarioContratacion,Porcentaje)  
		VALUES(@IDBeneficiarioContratacionEmpleado,@IDCatBeneficiarioContratacion,@Porcentaje)    

		SET @IDBeneficiarioContratacionEmpleadoDetalle = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblBeneficiarioContratacionEmpleadoDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDBeneficiarioContratacionEmpleadoDetalle = @IDBeneficiarioContratacionEmpleadoDetalle

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblBeneficiarioContratacionEmpleadoDetalle]','[RH].[spIUBeneficiarioContratacionEmpleadoDetalle]','INSERT',@NewJSON,''

    END  
    ELSE  
    BEGIN  

	
		select @OldJSON =  a.JSON from [RH].[tblBeneficiarioContratacionEmpleadoDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDBeneficiarioContratacionEmpleadoDetalle = @IDBeneficiarioContratacionEmpleadoDetalle


    UPDATE [RH].[tblBeneficiarioContratacionEmpleadoDetalle]
        SET IDCatBeneficiarioContratacion = @IDCatBeneficiarioContratacion,  
        Porcentaje = @Porcentaje 
    WHERE IDBeneficiarioContratacionEmpleado = @IDBeneficiarioContratacionEmpleado
        and IDBeneficiarioContratacionEmpleadoDetalle = @IDBeneficiarioContratacionEmpleadoDetalle

		
		select @NewJSON = a.JSON from [RH].[tblBeneficiarioContratacionEmpleadoDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDBeneficiarioContratacionEmpleadoDetalle = @IDBeneficiarioContratacionEmpleadoDetalle

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblBeneficiarioContratacionEmpleadoDetalle]','[RH].[spIUBeneficiarioContratacionEmpleadoDetalle]','UPDATE',@NewJSON,@OldJSON

    END;  
  
END
GO
